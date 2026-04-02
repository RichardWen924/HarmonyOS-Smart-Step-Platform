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
    //TODO 进行正式jwt验证的时候记得修改开关
    /**
     * JWT 校验开关（开发/测试环境专用）
     * 1: 开启校验 (开启安全验证)
     * 0: 关闭校验 (直接跳过验证，使用 Mock 数据)
     */
    private static final int JWT_SWITCH = 0;

    /**
     * 关闭 JWT 校验时使用的 Mock 用户 ID
     */
    private static final Long MOCK_USER_ID = 1L;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        log.info("拦截请求:{}",request.getRequestURI());

        // 1. 检查开关：如果关闭了 JWT 校验，则直接注入 Mock 用户并放行
        if (JWT_SWITCH == 0) {
            log.warn(" JWT 校验已关闭！正在使用 Mock 用户 ID: {}", MOCK_USER_ID);
            UserContext.setUserId(MOCK_USER_ID);
            return true;
        }

        // 2. 从 Header 获取 Token
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
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            log.error("Token已过期: {}", e.getMessage());
            throw new BusinessException("Token已过期", 401);
        } catch (io.jsonwebtoken.SignatureException e) {
            log.error("Token签名不匹配! 可能是密钥已更改或Token被篡改: {}", e.getMessage());
            throw new BusinessException("Token签名非法", 401);
        } catch (io.jsonwebtoken.PrematureJwtException e) {
            log.error("Token尚未生效(iat比当前时间晚): {}", e.getMessage());
            throw new BusinessException("Token尚未生效", 401);
        } catch (Exception e) {
            log.error("Token验证失败: {}", e.getMessage(), e);
            throw new BusinessException("Token验证失败", 401);
        }
    }
}