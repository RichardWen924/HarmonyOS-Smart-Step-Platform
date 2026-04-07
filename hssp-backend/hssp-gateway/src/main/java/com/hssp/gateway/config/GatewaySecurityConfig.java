package com.hssp.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

/**
 * 响应式网关安全配置 - 解决 403 Forbidden (CSRF) 与权限冲突。
 */
@Configuration
@EnableWebFluxSecurity
public class GatewaySecurityConfig {

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        http.csrf().disable() // 必须禁用 CSRF 防弃，否则非 GET 请求会被拦截返回 403
            .authorizeExchange()
            .anyExchange().permitAll(); // 网关只做流量分发与过滤器拦截，放行原始权限交给拦截器

        return http.build();
    }
}
