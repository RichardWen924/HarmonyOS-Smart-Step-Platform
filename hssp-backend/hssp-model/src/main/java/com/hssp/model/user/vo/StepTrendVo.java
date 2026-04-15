package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 步数趋势数据VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StepTrendVo {
    private String date;        // 日期 (yyyy-MM-dd)
    private Integer steps;      // 步数
}
