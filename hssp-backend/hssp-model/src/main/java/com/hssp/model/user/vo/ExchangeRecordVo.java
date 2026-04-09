package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 兑换记录VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExchangeRecordVo {
    private Long id;
    private Integer steps;           // 兑换步数
    private Integer points;          // 获得积分
    private LocalDateTime exchangeTime; // 兑换时间
    private String status;           // 状态: success/failed
}
