package com.hssp.service;

import com.hssp.service.service.MailService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;


import java.util.concurrent.TimeUnit;

@SpringBootTest
class MailServiceImplTest {

    @Autowired
    private MailService mailService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Test
    void testSendCode() {
        // 1. 定义接收邮箱（替换为你自己的测试邮箱）
        String testEmail = "2184987541@qq.com";

        // 2. 调用发送方法
        System.out.println("--- 正在发送验证码 ---");
        mailService.sendCode(testEmail);
        System.out.println("--- 验证码已发送，请检查收件箱 ---");

        // 3. 验证 Redis 中是否成功存入
        String redisKey = "EMAIL_CODE:" + testEmail;
        Object code = redisTemplate.opsForValue().get(redisKey);

        if (code != null) {
            System.out.println("Redis 验证成功！存入的验证码为: " + code);
            System.out.println("剩余有效期(秒): " + redisTemplate.getExpire(redisKey, TimeUnit.SECONDS));
        } else {
            System.err.println("Redis 中未找到验证码，请检查 Redis 配置或代码逻辑！");
        }
    }
}