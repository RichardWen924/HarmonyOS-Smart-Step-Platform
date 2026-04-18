package com.hssp.model.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

/**
 * 步数上传请求DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StepUploadDto {
    @NotNull(message = "步数不能为空")
    private Integer steps;
    
    private String date; // 日期,格式: yyyy-MM-dd,不传则默认为今天
}
