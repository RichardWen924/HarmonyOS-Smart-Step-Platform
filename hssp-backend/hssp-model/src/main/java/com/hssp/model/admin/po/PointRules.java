package com.hssp.model.admin.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.hssp.common.admin.PointRules_Status;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName("points_rule")
public class PointRules {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String ruleName;
    private Integer stepsRequired;
    private Integer pointsAwarded;
    @TableField("is_active")
    private PointRules_Status isActive;
}
