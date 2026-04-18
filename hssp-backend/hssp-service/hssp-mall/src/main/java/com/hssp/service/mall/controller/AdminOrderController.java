package com.hssp.service.mall.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.service.mall.service.MallOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/order/admin")
public class AdminOrderController {

    @Autowired
    private MallOrderService mallOrderService;

    @PutMapping("/status")
    public Result updateStatus(@RequestBody OrderStatusUpdateDto dto) {
        if (dto.getOrderId() == null) {
            return Result.error("订单ID不能为空");
        }
        try {
            mallOrderService.updateOrderStatus(dto);
            return Result.success("更新订单状态成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
