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
        // 1. 生成 6 位随机数TODO为了调试方便，固定为123456
//        String code = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));

        String code="123456";
        // 2. 创建邮件消息
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject("【XX系统】验证码校验");
        message.setText("您的验证码为：" + code + "，有效期 5 分钟。请勿泄露。");

        try {
            // 3. 发送邮件（这是一个耗时操作）TODO 发送到QQ邮箱
//            mailSender.send(message);
            log.info("sendCode: {}", code);
            // 4. 存入 Redis
            redisTemplate.opsForValue().set(CODE_PREFIX + to, code, 5, TimeUnit.MINUTES);

        } catch (Exception e) {
            throw new BusinessException("邮件发送失败：" + e.getMessage());
        }
    }
}