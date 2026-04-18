package com.hssp.service.mall.controller;

import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.ExchangeOrderDto;
import com.hssp.service.mall.service.MallOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired
    private MallOrderService mallOrderService;


    @PostMapping("/exchange")
    public Result exchange(@RequestBody ExchangeOrderDto dto) {
        if (dto.getGoodsId() == null) {
            return Result.error("商品ID不能为空");
        }
        
        try {
            Long userId = UserContext.getUserId();
            mallOrderService.exchangeOrder(dto.getGoodsId(), userId);
            return Result.success("兑换成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result list() {
        Long userId = UserContext.getUserId();
        return Result.success(mallOrderService.listUserOrders(userId));
    }
}
