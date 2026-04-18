package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hssp.common.result.Result;
import com.hssp.model.user.dto.UserDto;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.UserVo;
import com.hssp.service.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/user")
@RequiredArgsConstructor
public class UserController {

    private final PasswordEncoder passwordEncoder;

    private static final String DEFAULT_PASSWORD = "123456";

    @Autowired
    private UserService userService;

    @GetMapping()
    public Result list() {
        List<User> users = userService.list();
        List<UserVo> userVos = BeanUtil.copyToList(users, UserVo.class);
        return Result.success(userVos);
    }

    @GetMapping("/{id}")
    public Result getById(@PathVariable Long id) {
        User user = userService.getById(id);
        UserVo userVo = BeanUtil.copyProperties(user, UserVo.class);
        return Result.success(userVo);
    }

    @PutMapping()
    public Result update(@RequestBody UserDto userDto) {
        User user = BeanUtil.copyProperties(userDto, User.class);
        userService.updateById(user);
        return Result.success();
    }

    @DeleteMapping("/{ids}")
    public Result deleteBatchByIds(@PathVariable List<Long> ids) {
        userService.removeBatchByIds(ids);
        return Result.success();
    }

    @GetMapping("/page")
    public Result page(@RequestParam(defaultValue = "1") Integer current,
                       @RequestParam(defaultValue = "2") Integer size) {
        Page<User> page = new Page<User>(current, size);
        Page<User> userPage = userService.page(page);
        List<UserVo> userVOList = userPage.getRecords().stream()
                .map(user -> {
                    UserVo vo = new UserVo();
                    BeanUtils.copyProperties(user, vo);
                    return vo;
                }).collect(Collectors.toList());
        Page<UserVo> voPage = new Page<>(userPage.getCurrent(), userPage.getSize(), userPage.getTotal());
        voPage.setRecords(userVOList);
        return Result.success(voPage);
    }

    @PutMapping("/password")
    public Result resetPassword(@RequestParam Long id) {
            User user = userService.getById(id);
            user.setPassword(passwordEncoder.encode(DEFAULT_PASSWORD));
            userService.updateById(user);
        return Result.success();
    }

}
