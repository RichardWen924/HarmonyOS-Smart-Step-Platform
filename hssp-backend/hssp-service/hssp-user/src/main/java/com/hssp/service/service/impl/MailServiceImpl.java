package com.hssp.service.service.impl;

import com.hssp.common.exception.BusinessException;
import com.hssp.service.service.MailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class MailServiceImpl implements MailService {

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Value("${spring.mail.username}")
    private String from;

    private static final String CODE_PREFIX = "EMAIL_CODE:";

    @Override
    public void sendCode(String to) {
        // 1. 生成 6 位随机验证码
        String code = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
        
        // 2. 存入 Redis（先存Redis，确保后续验证可用）
        redisTemplate.opsForValue().set(CODE_PREFIX + to, code, 5, TimeUnit.MINUTES);
        log.info("✅ 验证码已保存到Redis - 邮箱: {}, 验证码: {}, 有效期: 5分钟", to, code);
        String separator = "================================================================================";
        System.out.println("\n" + separator);
        System.out.println("🔐 验证码信息:");
        System.out.println("   邮箱: " + to);
        System.out.println("   验证码: " + code);
        System.out.println("   有效期: 5分钟");
        System.out.println("   Redis Key: " + CODE_PREFIX + to);
        System.out.println(separator + "\n");
        
        // 3. 创建邮件消息
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject("【XX系统】验证码校验");
        message.setText("您的验证码为：" + code + "，有效期 5 分钟。请勿泄露。");

        log.info("发送到：{}", to);

        try {
            // 4. 发送邮件（这是一个耗时操作）TODO 发送到QQ邮箱
            mailSender.send(message);
            log.info("sendCode: {}", code);

        } catch (Exception e) {
            log.error("邮件发送失败: {}", e.getMessage());
            // 注意：即使邮件发送失败，验证码仍然保存在Redis中，可以用于测试
            throw new BusinessException("邮件发送失败：" + e.getMessage());
        }
    }
}