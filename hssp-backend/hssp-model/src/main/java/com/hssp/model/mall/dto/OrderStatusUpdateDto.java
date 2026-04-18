package com.hssp.model.mall.dto;

import lombok.Data;
import java.io.Serializable;

@Data
public class OrderStatusUpdateDto implements Serializable {
    private Long orderId;
    /**
     * 0:待发货, 1:已发货, 2:已完成, 3:已取消
     */
    private Integer status;
    private String trackingNumber;
}
