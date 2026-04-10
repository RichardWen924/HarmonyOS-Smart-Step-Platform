package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 兑换记录VO - 统一返回步数记录和积分兑换记录
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExchangeRecordVo {
    private Long id;
    private String type;             // 类型: step_record(步数记录), points_exchange(积分兑换)
    private Integer steps;           // 步数（步数记录时有值）
    private Integer points;          // 积分（积分兑换时有值）
    private LocalDateTime exchangeTime; // 时间
    private String description;      // 描述
}
