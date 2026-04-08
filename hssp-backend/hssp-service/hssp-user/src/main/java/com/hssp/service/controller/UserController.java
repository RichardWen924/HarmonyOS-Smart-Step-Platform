package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.hssp.common.result.Result;
import com.hssp.model.user.dto.*;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.UserVo;
import com.hssp.service.service.IUserService;
import com.hssp.service.service.MailService;
import com.hssp.service.service.impl.MailServiceImpl;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@Validated
public class UserController {
    private final IUserService userService;
    private final MailService mailService;

    @RequestMapping("/register")
    public Result register(@Valid @RequestBody RegisterDto registerDto) {
        log.info("register:{}", registerDto);
        userService.register(registerDto);
        return Result.success("注册成功");
    }

    @PostMapping("/send-verification")
    public Result sendVerification(@Valid @RequestBody EmailDto emailDto) {
        log.info("sendVerification: {}", emailDto);
        mailService.sendCode(emailDto.getEmail());
        return Result.success("验证码发送成功");
    }


    @PostMapping("/login")
    public Result login(@Valid @RequestBody LoginDto loginDto) {
        log.info("login:{}", loginDto);
        String token = userService.login(loginDto);
        return Result.success("登录成功", token);
    }

    @PutMapping
    public Result update(@Valid @RequestBody ChangeInfoDto changeInfoDto) {
        log.info("update:{}", changeInfoDto);
        userService.update(changeInfoDto);
        return Result.success("更新用户信息成功");
    }


    @PutMapping("/password")
    public Result updatePassword(@Valid @RequestBody ChangePasswordDto changePasswordDto) {
        userService.updatePassword(changePasswordDto);
        return Result.success("密码更新成功");
    }

    @GetMapping("/points")
    public Result getPoints() {
        return Result.success(userService.getPoints());
    }

    @GetMapping()
    public Result list() {
        List<User> users = userService.list();
        List<UserVo> userVos = BeanUtil.copyToList(users, UserVo.class);
        return Result.success(userVos);
    }

    @GetMapping("/{id}")
    public Result list(@PathVariable Long id) {
        User user = userService.getById(id);
        UserVo userVo = BeanUtil.copyProperties(user, UserVo.class);
        return Result.success(userVo);
    }

}
