package com.hssp.model.mall.po;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

@Data
@TableName("user_points")
public class UserPoints implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId
    private Long userId;

    private Integer totalPoints;

    private Integer cumulativePoints;

    private Date updateTime;
}
