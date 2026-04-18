package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 步数统计VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StepStatisticsVo {
    private Integer todaySteps;      // 今日步数
    private Integer weekSteps;       // 本周步数
    private Integer monthSteps;      // 本月步数
    private Integer totalSteps;      // 总步数
    private Double avgDailySteps;    // 平均每日步数
    private Integer maxDailySteps;   // 最大日步数
    private Integer minDailySteps;   // 最小日步数
    private String lastUpdate;       // 最后更新时间
}
