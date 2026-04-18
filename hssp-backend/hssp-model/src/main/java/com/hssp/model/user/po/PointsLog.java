package com.hssp.model.user.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 积分兑换日志实体类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("points_log")
public class PointsLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;          // 用户ID
    
    private Integer beforeStep;   // 兑换前的步数
    
    private Integer afterStep;    // 兑换后的步数
    
    private Integer pointsAmount; // 兑换获得的积分
    
    private LocalDateTime createTime; // 兑换时间
}
