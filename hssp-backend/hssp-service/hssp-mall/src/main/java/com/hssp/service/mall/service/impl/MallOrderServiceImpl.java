package com.hssp.service.mall.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.mall.dto.OrderStatusUpdateDto;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.model.mall.po.MallOrder;
import com.hssp.model.user.po.User;
import com.hssp.service.mall.mapper.MallGoodsMapper;
import com.hssp.service.mall.mapper.MallOrderMapper;
import com.hssp.service.mall.mapper.UserMapper;
import com.hssp.service.mall.service.MallGoodsService;
import com.hssp.service.mall.service.MallOrderService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

@Service
@Slf4j
public class MallOrderServiceImpl extends ServiceImpl<MallOrderMapper, MallOrder> implements MallOrderService {

    @Autowired
    private MallGoodsMapper mallGoodsMapper;

    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private MallGoodsService mallGoodsService;

    @Override
    @Transactional
    public void exchangeOrder(Long goodsId, Long userId) {
        System.out.println("=== MallOrderService: 开始兑换 ===");
        System.out.println("商品ID: " + goodsId);
        System.out.println("用户ID: " + userId);
        
        // 1. 获取商品详情
        MallGoods goods = mallGoodsMapper.selectById(goodsId);
        if (goods == null) {
            System.err.println("商品不存在: goodsId=" + goodsId);
            throw new RuntimeException("商品不存在");
        }
        System.out.println("商品信息: " + goods.getGoodsName() + ", 所需积分: " + goods.getRequiredPoints());

        // 2. 从 user 表获取用户积分
        User user = userMapper.selectById(userId);
        System.out.println("用户记录: " + (user != null ? "存在" : "不存在"));
        if (user != null) {
            System.out.println("用户名: " + user.getUsername());
            System.out.println("用户总积分: " + user.getTotalPoints());
        }
        
        if (user == null) {
            System.err.println("用户不存在: userId=" + userId);
            throw new RuntimeException("用户不存在");
        }
        
        if (user.getTotalPoints() < goods.getRequiredPoints()) {
            System.err.println("积分不足: 当前=" + user.getTotalPoints() + ", 需要=" + goods.getRequiredPoints());
            throw new RuntimeException("积分不足，当前积分: " + user.getTotalPoints() + "，需要: " + goods.getRequiredPoints());
        }

        System.out.println("积分校验通过，开始扣减积分...");
        
        // 3. 扣减 user 表中的积分
        user.setTotalPoints(user.getTotalPoints() - goods.getRequiredPoints());
        user.setUpdateTime(LocalDateTime.now());
        int userUpdateResult = userMapper.updateById(user);
        System.out.println("用户积分更新结果: " + userUpdateResult + " 行");

        // 4. 检查并扣减库存
        if (goods.getStock() == null || goods.getStock() <= 0) {
            System.err.println("商品库存不足: stock=" + goods.getStock());
            throw new RuntimeException("商品库存不足");
        }
        
        goods.setStock(goods.getStock() - 1);
        System.out.println("扣减库存: 原库存=" + (goods.getStock() + 1) + ", 新库存=" + goods.getStock());
        
        // 5. 增加销量（使用 displayNum）
        if (goods.getDisplayNum() == null) {
            goods.setDisplayNum(0);
        }
        goods.setDisplayNum(goods.getDisplayNum() + 1);
        System.out.println("增加销量: 新销量=" + goods.getDisplayNum());
        
        int goodsUpdateResult = mallGoodsMapper.updateById(goods);
        System.out.println("商品信息更新结果: " + goodsUpdateResult + " 行");

        // 6. 插入订单记录
        MallOrder order = new MallOrder();
        order.setUserId(userId);
        order.setGoodsId(goodsId);
        order.setPointsConsumed(goods.getRequiredPoints());
        order.setStatus(0); // 0: 待发货
        order.setExchangeTime(new Date());
        int orderInsertResult = baseMapper.insert(order);
        System.out.println("订单插入结果: " + orderInsertResult + " 行");
        
        System.out.println("=== MallOrderService: 兑换成功 ===");
        
        // 7. 清除商品缓存（在事务提交后执行）
        // 使用 @Transactional 的 afterCommit 回调确保在事务提交后清除缓存
        org.springframework.transaction.support.TransactionSynchronizationManager.registerSynchronization(
            new org.springframework.transaction.support.TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    try {
                        mallGoodsService.refreshGoodsCache();
                        System.out.println("已清除商品缓存（事务提交后）");
                    } catch (Exception e) {
                        System.err.println("清除商品缓存失败: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
        );
    }

    @Override
    public List<MallOrder> listUserOrders(Long userId) {
        return baseMapper.selectList(new LambdaQueryWrapper<MallOrder>()
                .eq(MallOrder::getUserId, userId)
                .orderByDesc(MallOrder::getExchangeTime));
    }

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

    @Override
    public List<MallOrder> listUserOrders(Long userId) {
        return baseMapper.selectList(new LambdaQueryWrapper<MallOrder>()
                .eq(MallOrder::getUserId, userId)
                .orderByDesc(MallOrder::getExchangeTime));
    }

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
