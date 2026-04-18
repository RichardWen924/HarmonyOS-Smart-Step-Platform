package com.hssp.service.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.service.service.AdminMallOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/order")
public class AdminMallOrderController {

    @Autowired
    private AdminMallOrderService adminMallOrderService;

    @PutMapping("/status")
    public Result updateStatus(@RequestBody OrderStatusUpdateDto dto) {
        if (dto.getOrderId() == null) {
            return Result.error("订单ID不能为空");
        }
        try {
            adminMallOrderService.updateOrderStatus(dto);
            return Result.success("更新订单状态成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
