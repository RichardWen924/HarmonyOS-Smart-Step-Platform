package com.hssp.common.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

public class JwtUtils {
    // 过期时间（例如：24小时）
    //TODO 记得检查jwt校验部分是否生效
    private static final long EXPIRATION_TIME = 24 * 60 * 60 * 1000;
    /*
    正式jwt校验，我先注解掉测试使用
     */
    //private static final Key SECRET_KEY = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    /**
     * 固定、共用的密钥 - 彻底解决应用重启后 Token 会失效的问题。
     * 在生产环境中，建议将该值通过 Nacos 或 环境变量 注入。
     * 仅测试使用------Wen
     */
    private static final String SECRET_STR = "aHNzcF9zbWFydF9zdGVwX3BsYXRmb3JtX3NlY3JldF9rZXlfMjAyNl8wNF8wMg==";
    private static final Key SECRET_KEY = Keys.hmacShaKeyFor(SECRET_STR.getBytes(StandardCharsets.UTF_8));

    /**
     * 生成令牌
     */
    public static String createToken(Long userId) {
        return Jwts.builder()
                .setSubject("USER_INFO")
                .claim("userId", userId)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    /**
     * 解析令牌
     */
    public static Claims parseToken(String token) {
        return Jwts.parser()
                .setSigningKey(SECRET_KEY)
                // 允许 120 秒的时钟偏差，避免因服务器时间微弱差异导致的 iat (未来 Token) 或 exp 解析失败
                .setAllowedClockSkewSeconds(120)
                .parseClaimsJws(token)
                .getBody();
    }
}