package com.hssp.service.controller;

import com.hssp.model.admin.dto.RegisterDto;
import com.hssp.model.admin.dto.SendVerificationDto;
import com.hssp.common.result.Result;
import com.hssp.model.admin.dto.LoginDto;
import com.hssp.model.user.dto.EmailDto;
import com.hssp.service.service.AdminService;
import com.hssp.service.service.MailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@RestController
@RequestMapping("/admin")
@Slf4j
public class AdminController {

    @Autowired
    private AdminService adminService;

    @Autowired
    private MailService mailService;

    /**
     * 管理员注册
     * @param registerDto
     * @return
     */
    @PostMapping("/register")
    public Result register(@Valid @RequestBody RegisterDto registerDto) {
        log.info("管理员注册:{}", registerDto);
        adminService.register(registerDto);
        return Result.success("注册成功");
    }

    @PostMapping("/login")
    public Result login(@Valid @RequestBody LoginDto loginDto) {
        log.info("管理员login:{}", loginDto);
        String token = adminService.login(loginDto);
        return Result.success("登录成功", token);
    }


    /**
     * 发送验证码
     * @param sendVerificationDto
     * @return
     */
    @PostMapping("/send-verification")
    public Result sendVerification(@Valid @RequestBody SendVerificationDto sendVerificationDto) {
        log.info("sendVerification: {}", sendVerificationDto);
        mailService.sendCode(sendVerificationDto.getEmail());
        return Result.success("验证码发送成功");
    }


}
