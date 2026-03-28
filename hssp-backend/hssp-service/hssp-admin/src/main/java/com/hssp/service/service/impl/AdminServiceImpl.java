package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.admin.dto.LoginDto;
import com.hssp.model.admin.dto.RegisterDto;
import com.hssp.model.admin.po.Admin;
import com.hssp.service.mapper.AdminMapper;
import com.hssp.service.service.AdminService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class AdminServiceImpl extends ServiceImpl<AdminMapper,Admin> implements AdminService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Override
    public Boolean register(RegisterDto registerDto) {
        String email = registerDto.getEmail();
        String verification = registerDto.getVerification();

        String redisKey = "EMAIL_CODE:" + email;
        Object code = redisTemplate.opsForValue().get(redisKey);

        if (code.toString().equals(verification)) {
            Admin admin = new Admin();
            admin.setEmail(email);
            // TODO 优化密码
            admin.setPassword("123456");
            // TODO 优化用户名
            admin.setUsername("123456");
            // TODO 图片
            //admin.setAvatar();
            admin.setCreateTime(LocalDateTime.now());
            admin.setUpdateTime(LocalDateTime.now());
            this.save(admin);
            return true;
        }
        return false;
    }
}
