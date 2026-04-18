package com.hssp.service.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.model.mall.po.MallOrder;

public interface AdminMallOrderService extends IService<MallOrder> {
    void updateOrderStatus(OrderStatusUpdateDto dto);
}
