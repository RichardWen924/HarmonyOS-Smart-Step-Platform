package com.hssp.model.mall.dto;

import lombok.Data;

@Data
public class ExchangePointsDto {
    private Integer steps;
    private Long ruleId; // 可选，指定使用的积分规则ID
}
