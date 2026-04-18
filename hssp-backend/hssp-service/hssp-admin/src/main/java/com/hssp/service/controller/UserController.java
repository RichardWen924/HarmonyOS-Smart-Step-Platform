package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.hssp.common.result.Result;
import com.hssp.model.user.dto.UserDto;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.UserVo;
import com.hssp.service.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/user")
public class UserController {

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

}
