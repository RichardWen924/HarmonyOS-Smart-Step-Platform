package com.hssp.model.mall.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

@Data
@TableName("mall_order")
public class MallOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    private Long userId;

    private Long goodsId;

    private Integer pointsConsumed;
    
    /**
     * 订单状态：0:待发货, 1:已发货, 2:已完成, 3:已取消
     */
    private Integer status;

    /**
     * 物流单号
     */
    private String trackingNumber;

    private Date exchangeTime;
}
