package com.hssp.service.controller;

import com.hssp.model.admin.dto.RegisterDto;
import com.hssp.model.admin.dto.SendVerificationDto;
import com.hssp.common.result.Result;
import com.hssp.service.service.AdminService;
import com.hssp.service.service.MailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
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
    public Result register(@RequestBody RegisterDto registerDto) {
        Boolean registered = adminService.register(registerDto);
        if (registered) {
            return Result.success();
        }
        return Result.error("验证码错误或验证码已失效");
    }

    /**
     * 发送验证码
     * @param sendVerificationDto
     * @return
     */
    @PostMapping("/send-verification")
    public Result sendVerification(@RequestBody SendVerificationDto sendVerificationDto) {
        mailService.sendCode(sendVerificationDto.getEmail());
        return Result.success();
    }

}
