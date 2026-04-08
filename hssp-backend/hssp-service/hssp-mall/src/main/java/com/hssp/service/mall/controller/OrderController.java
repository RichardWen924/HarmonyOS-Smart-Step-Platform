package com.hssp.service.mall.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.ExchangeOrderDto;
import com.hssp.service.mall.service.MallOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired
    private MallOrderService mallOrderService;

    // TODO: 之后迁移至 Token 获取 UserId
    private Long mockUserId = 1L;

    @PostMapping("/exchange")
    public Result exchange(@RequestBody ExchangeOrderDto dto) {
        if (dto.getGoodsId() == null) {
            return Result.error("商品ID不能为空");
        }
        
        try {
            mallOrderService.exchangeOrder(dto.getGoodsId(), mockUserId);
            return Result.success("兑换成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
