package com.hssp.model.user.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 每日步数记录实体类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("step_record")
public class StepRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;           // 用户ID
    
    private LocalDate recordDate;  // 记录日期 (YYYY-MM-DD)
    
    private Integer stepCount;     // 今日步数累计
    
    private LocalDateTime lastUploadTime;  // 最后同步时间
}
