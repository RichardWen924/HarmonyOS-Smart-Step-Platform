package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.user.dto.*;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.ExchangeRecordVo;
import com.hssp.model.user.vo.StepRecordVo;
import com.hssp.model.user.vo.StepStatisticsVo;
import com.hssp.model.user.vo.StepTrendVo;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
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

    /**
     * 验证码登录 (前端需要)
     */
    @PostMapping("/login-by-code")
    public Result loginByCode(@Valid @RequestBody LoginDto loginDto) {
        log.info("loginByCode:{}", loginDto);
        // 复用现有的login方法,LoginDto中已有verification字段
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

    /**
     * 获取当前登录用户信息 (前端“我的”页面需要)
     */
    @GetMapping("/info")
    public Result getCurrentUserInfo() {
        Long userId = UserContext.getUserId();
        log.info("获取当前用户信息, userId:{}", userId);
        
        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }
        
        UserVo userVo = BeanUtil.copyProperties(user, UserVo.class);
        return Result.success(userVo);
    }

    @GetMapping()
    public Result list() {
        List<User> users = userService.list();
        List<UserVo> userVos = BeanUtil.copyToList(users, UserVo.class);
        return Result.success(userVos);
    }

    @GetMapping("/{id}")
    public Result getUserById(@PathVariable Long id) {
        User user = userService.getById(id);
        UserVo userVo = BeanUtil.copyProperties(user, UserVo.class);
        return Result.success(userVo);
    }

    /**
     * 上传步数 (前端需要)
     */
    @PostMapping("/steps/upload")
    public Result uploadSteps(@Valid @RequestBody StepUploadDto stepUploadDto) {
        log.info("uploadSteps:{}", stepUploadDto);
        Long userId = UserContext.getUserId();
        userService.uploadSteps(stepUploadDto);
        return Result.success("步数上传成功");
    }

    /**
     * 获取步数统计 (前端需要)
     */
    @GetMapping("/steps/statistics")
    public Result getStepStatistics(@RequestParam(required = false) String date) {
        log.info("getStepStatistics, date:{}", date);
        StepStatisticsVo statistics = userService.getStepStatistics();
        return Result.success(statistics);
    }

    /**
     * 获取步数趋势数据 (数据分析)
     */
    @GetMapping("/steps/trend")
    public Result getStepTrend(@RequestParam(defaultValue = "7") int days) {
        log.info("getStepTrend, days:{}", days);
        List<StepTrendVo> trendList = userService.getStepTrend(days);
        return Result.success(trendList);
    }

    /**
     * 获取步数记录列表 (用于RecordPage)
     */
    @GetMapping("/steps/records")
    public Result getStepRecords(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        log.info("getStepRecords, pageNum:{}, pageSize:{}", pageNum, pageSize);
        List<StepRecordVo> records = userService.getStepRecords(pageNum, pageSize);
        return Result.success(records);
    }

    /**
     * 获取兑换记录 (前端需要)
     */
    @GetMapping("/exchange/records")
    public Result getExchangeRecords(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        log.info("getExchangeRecords, pageNum:{}, pageSize:{}", pageNum, pageSize);
        List<ExchangeRecordVo> records = userService.getExchangeRecords(pageNum, pageSize);
        return Result.success(records);
    }
}
