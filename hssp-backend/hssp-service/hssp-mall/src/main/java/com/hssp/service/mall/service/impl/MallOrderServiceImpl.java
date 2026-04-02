package com.hssp.service.mall.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.model.mall.po.MallOrder;
import com.hssp.model.mall.po.UserPoints;
import com.hssp.service.mall.mapper.MallGoodsMapper;
import com.hssp.service.mall.mapper.MallOrderMapper;
import com.hssp.service.mall.mapper.UserPointsMapper;
import com.hssp.service.mall.service.MallOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

@Service
public class MallOrderServiceImpl extends ServiceImpl<MallOrderMapper, MallOrder> implements MallOrderService {

    @Autowired
    private MallGoodsMapper mallGoodsMapper;

    @Autowired
    private UserPointsMapper userPointsMapper;

    @Override
    @Transactional
    public void exchangeOrder(Long goodsId, Long userId) {
        // 1. 获取商品详情
        MallGoods goods = mallGoodsMapper.selectById(goodsId);
        if (goods == null) {
            throw new RuntimeException("商品不存在");
        }

        // 2. 校验积分
        UserPoints userPoints = userPointsMapper.selectById(userId);
        if (userPoints == null || userPoints.getTotalPoints() < goods.getRequiredPoints()) {
            throw new RuntimeException("积分不足，无法兑换");
        }

        // 3. 扣减积分
        userPoints.setTotalPoints(userPoints.getTotalPoints() - goods.getRequiredPoints());
        userPoints.setUpdateTime(new Date());
        userPointsMapper.updateById(userPoints);

        // 4. 增加销量/库存
        goods.setDisplayNum(goods.getDisplayNum() + 1);
        mallGoodsMapper.updateById(goods);

        // 5. 插入订单记录
        MallOrder order = new MallOrder();
        order.setUserId(userId);
        order.setGoodsId(goodsId);
        order.setPointsConsumed(goods.getRequiredPoints());
        order.setExchangeTime(new Date());
        baseMapper.insert(order);
    }
}
