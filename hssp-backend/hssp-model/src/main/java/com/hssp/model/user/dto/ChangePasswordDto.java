package com.hssp.model.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChangePasswordDto {
    //TODO 这里要直接用threadLocal获取用户id吗？
    @NotNull(message = "用户id不能为空")
    private Long id;
    private String oldPassword;
    private String newPassword;
}
