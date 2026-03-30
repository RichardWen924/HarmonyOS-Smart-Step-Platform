package com.hssp.common.interceptor;

import com.hssp.common.context.UserContext;
import com.hssp.common.exception.BusinessException;
import com.hssp.common.utils.JwtUtils;
import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
@Slf4j
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        log.info("拦截请求:{}",request.getRequestURI());
        // 1. 从 Header 获取 Token
        String token = request.getHeader("Authorization");
        log.info("token:{}",token);
        if (!StringUtils.hasText(token)) {
            throw new BusinessException("未登录", 401);
        }
        try {
            // 2. 解析 Token
            Claims claims = JwtUtils.parseToken(token);
            // 3. 将用户信息存入 ThreadLocal，方便后续 Service 获取当前登录人
            UserContext.setUserId(Long.valueOf(claims.get("userId").toString()));
            log.info("用户登录userId: {}", UserContext.getUserId());
            return true;
        } catch (Exception e) {
            log.error("Token验证失败", e);
            throw new BusinessException("Token验证失败", 401);
        }
    }
}