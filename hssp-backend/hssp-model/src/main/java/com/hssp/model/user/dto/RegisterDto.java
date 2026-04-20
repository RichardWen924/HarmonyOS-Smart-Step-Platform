package com.hssp.model.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterDto {
    @NotNull(message = "用户名不能为空")
    private String username;
    
    @NotNull(message = "邮箱不能为空")
    @Email(message = "邮箱格式错误")
    private String email;

    @NotNull(message = "验证码不能为空")
    private String verification;
    
    @NotNull(message = "密码不能为空")
    private String password;
}
