package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.user.dto.*;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.ExchangeRecordVo;
import com.hssp.model.user.vo.StepStatisticsVo;
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
        // TODO: 调用Service保存步数
        // 目前先返回成功
        return Result.success("步数上传成功");
    }

    /**
     * 获取步数统计 (前端需要)
     */
    @GetMapping("/steps/statistics")
    public Result getStepStatistics(@RequestParam(required = false) String date) {
        log.info("getStepStatistics, date:{}", date);
        Long userId = UserContext.getUserId();
        
        // 构建模拟统计数据 (TODO: 后续从数据库查询)
        StepStatisticsVo statistics = new StepStatisticsVo();
        statistics.setTodaySteps(8500);
        statistics.setWeekSteps(52000);
        statistics.setMonthSteps(210000);
        statistics.setTotalSteps(500000);
        statistics.setAvgDailySteps(7500.0);
        statistics.setMaxDailySteps(15000);
        statistics.setMinDailySteps(2000);
        statistics.setLastUpdate(LocalDateTime.now().toString());
        
        return Result.success(statistics);
    }

    /**
     * 获取兑换记录 (前端需要)
     */
    @GetMapping("/exchange/records")
    public Result getExchangeRecords() {
        log.info("getExchangeRecords");
        Long userId = UserContext.getUserId();
        
        // 构建模拟兑换记录 (TODO: 后续从数据库查询)
        List<ExchangeRecordVo> records = new ArrayList<>();
        ExchangeRecordVo record1 = new ExchangeRecordVo();
        record1.setId(1L);
        record1.setSteps(5000);
        record1.setPoints(50);
        record1.setExchangeTime(LocalDateTime.now().minusDays(1));
        record1.setStatus("success");
        records.add(record1);
        
        return Result.success(records);
    }
}
