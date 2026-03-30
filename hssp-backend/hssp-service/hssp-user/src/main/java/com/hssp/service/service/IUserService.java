package com.hssp.service.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.user.dto.ChangeInfoDto;
import com.hssp.model.user.dto.ChangePasswordDto;
import com.hssp.model.user.dto.LoginDto;
import com.hssp.model.user.dto.RegisterDto;
import com.hssp.model.user.po.User;

public interface IUserService extends IService<User> {

    void register(RegisterDto registerDto);
    String login(LoginDto loginDto);
    void update(ChangeInfoDto changeInfoDto);
    void updatePassword(ChangePasswordDto changePasswordDto);
    Integer getPoints();
}
