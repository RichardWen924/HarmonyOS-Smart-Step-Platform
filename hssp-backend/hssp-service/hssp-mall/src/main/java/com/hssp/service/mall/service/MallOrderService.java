package com.hssp.service.mall.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.model.mall.po.MallOrder;
import java.util.List;

public interface MallOrderService extends IService<MallOrder> {
    void exchangeOrder(Long goodsId, Long userId);

    List<MallOrder> listUserOrders(Long userId);

    void updateOrderStatus(OrderStatusUpdateDto dto);
}
