package com.hssp.service.mall.controller;

import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.ExchangeOrderDto;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.mall.service.MallGoodsService;
import com.hssp.service.mall.service.MallOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商城统一控制器
 * 提供前端期望的 /mall 路径接口
 * 注意：通过网关访问时，/mall 前缀会被 StripPrefix 移除
 */
@RestController
@RequestMapping("/")  // 网关已移除 /mall 前缀，这里使用根路径
@RequiredArgsConstructor
public class MallController {

    private final MallGoodsService mallGoodsService;
    private final MallOrderService mallOrderService;

    /**
     * 获取商品列表（前端期望路径）
     */
    @GetMapping("/products")
    public Result getProducts() {
        try {
            System.out.println("=== MallController: 开始查询商品列表 ===");
            // 强制从数据库查询最新数据
            List<MallGoods> goodsList = mallGoodsService.list();
            System.out.println("=== MallController: 查询到 " + (goodsList != null ? goodsList.size() : 0) + " 个商品 ===");
            if (goodsList != null && !goodsList.isEmpty()) {
                System.out.println("第一个商品: " + goodsList.get(0).getGoodsName() + ", 库存: " + goodsList.get(0).getStock());
            }
            return Result.success(goodsList);
        } catch (Exception e) {
            System.err.println("=== MallController: 查询商品失败 ===");
            e.printStackTrace();
            return Result.error("查询商品失败: " + e.getMessage());
        }
    }

    /**
     * 兑换商品（前端期望路径）
     */
    @PostMapping("/products/exchange")  // 改为 /products/exchange 避免与 PointsController 冲突
    public Result exchangeProduct(@RequestBody ExchangeOrderDto dto) {
        System.out.println("=== MallController: 收到兑换请求 ===");
        System.out.println("商品ID: " + dto.getGoodsId());
        
        if (dto.getGoodsId() == null) {
            System.err.println("MallController: 商品ID为空");
            return Result.error("商品ID不能为空");
        }
        
        try {
            // 从 Token 中获取用户ID
            Long userId = UserContext.getUserId();
            System.out.println("MallController: 用户ID: " + userId);
            
            mallOrderService.exchangeOrder(dto.getGoodsId(), userId);
            System.out.println("MallController: 兑换成功");
            return Result.success("兑换成功", null);
        } catch (Exception e) {
            System.err.println("MallController: 兑换失败 - " + e.getMessage());
            e.printStackTrace();
            return Result.error(e.getMessage());
        }
    }
}
