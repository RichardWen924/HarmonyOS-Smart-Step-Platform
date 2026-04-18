package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.model.mall.po.MallOrder;
import com.hssp.service.mapper.MallOrderMapper;
import com.hssp.service.service.AdminMallOrderService;
import org.springframework.stereotype.Service;

@Service
public class AdminMallOrderServiceImpl extends ServiceImpl<MallOrderMapper, MallOrder> implements AdminMallOrderService {

    @Override
    public void updateOrderStatus(OrderStatusUpdateDto dto) {
        MallOrder order = baseMapper.selectById(dto.getOrderId());
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if (dto.getStatus() != null) {
            order.setStatus(dto.getStatus());
        }
        if (dto.getTrackingNumber() != null) {
            order.setTrackingNumber(dto.getTrackingNumber());
        }
        baseMapper.updateById(order);
    }
}
