package com.hssp.service.mall.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.user.po.UserPoints;
import com.hssp.service.mall.mapper.UserPointsMapper;
import com.hssp.service.mall.service.UserPointsService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

@Service
public class UserPointsServiceImpl extends ServiceImpl<UserPointsMapper, UserPoints> implements UserPointsService {

    @Override
    @Transactional
    public void exchangePoints(Integer steps, Long userId) {
        if (steps == null || steps < 1000) {
            throw new RuntimeException("步数不足1000，无法兑换积分");
        }

        // 1000:1 换算
        int earnedPoints = steps / 1000;

        // 查询当前积分记录
        UserPoints userPoints = baseMapper.selectById(userId);
        if (userPoints == null) {
            // 初始化积分记录
            userPoints = new UserPoints();
            userPoints.setUserId(userId);
            userPoints.setTotalPoints(earnedPoints);
            userPoints.setCumulativePoints(earnedPoints);
            userPoints.setUpdateTime(new Date());
            baseMapper.insert(userPoints);
        } else {
            // 更新积分记录
            userPoints.setTotalPoints(userPoints.getTotalPoints() + earnedPoints);
            userPoints.setCumulativePoints(userPoints.getCumulativePoints() + earnedPoints);
            userPoints.setUpdateTime(new Date());
            baseMapper.updateById(userPoints);
        }
    }
}
