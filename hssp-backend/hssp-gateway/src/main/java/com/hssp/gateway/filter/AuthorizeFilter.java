package com.hssp.gateway.filter;

import com.hssp.common.utils.JwtUtils;
import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.Arrays;
import java.util.List;

@Component
@Slf4j
public class AuthorizeFilter implements GlobalFilter, Ordered {

    // 白名单路径，不需要 Token 即可访问
    private static final List<String> WHITELIST = Arrays.asList(
            "/user/login",
            "/user/login-by-code",
            "/user/register",
            "/user/send-verification",  // 发送验证码接口
            "/mall/goods/list" // 允许匿名查看商品
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        ServerHttpResponse response = exchange.getResponse();

        String path = request.getURI().getPath();
        log.info("Gateway 拦截请求: {}", path);

        // 0. 放行 OPTIONS 预检请求（解决 CORS 问题）
        if (request.getMethod() != null && "OPTIONS".equalsIgnoreCase(request.getMethod().name())) {
            return chain.filter(exchange);
        }

        // 1. 白名单放行
        for (String whitePath : WHITELIST) {
            if (path.contains(whitePath)) {
                return chain.filter(exchange);
            }
        }

        // 2. 获取 Token
        String token = request.getHeaders().getFirst("Authorization");
        
        // 如果存在 "Bearer " 前缀，需要去除
        if (StringUtils.hasText(token) && token.startsWith("Bearer ")) {
            token = token.substring(7); // 去除 "Bearer " 前缀（7个字符）
        }
        
        if (!StringUtils.hasText(token)) {
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return response.setComplete();
        }

        try {
            // 3. 校验 Token
            Claims claims = JwtUtils.parseToken(token);
            String userId = claims.getSubject(); // 从 subject 中获取 userId
            
            if (!StringUtils.hasText(userId)) {
                log.error("Token中subject为空");
                response.setStatusCode(HttpStatus.UNAUTHORIZED);
                return response.setComplete();
            }

            // 4. 将 userId 注入 Header，传递给下游微服务
            ServerHttpRequest mutatedRequest = request.mutate()
                    .header("user-id", userId)
                    .build();

            log.info("✅ Token 校验通过，userId: {}", userId);

            // 5. 放行
            return chain.filter(exchange.mutate().request(mutatedRequest).build());

        } catch (Exception e) {
            log.error("Token 校验失败: {}", e.getMessage());
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return response.setComplete();
        }
    }

    @Override
    public int getOrder() {
        return 0; // 过滤器优先级，越小越高
    }
}
