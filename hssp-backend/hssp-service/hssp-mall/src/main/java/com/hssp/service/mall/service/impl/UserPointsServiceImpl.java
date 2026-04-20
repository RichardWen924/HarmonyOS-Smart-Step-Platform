package com.hssp.service.mall.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hssp.common.admin.PointRules_Status;
import com.hssp.model.admin.po.PointRules;
import com.hssp.model.user.po.PointsLog;
import com.hssp.model.user.po.User;
import com.hssp.service.mall.mapper.PointRulesMapper;
import com.hssp.service.mall.mapper.PointsLogMapper;
import com.hssp.service.mall.mapper.UserMapper;
import com.hssp.service.mall.service.UserPointsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserPointsServiceImpl implements UserPointsService {

    private final PointRulesMapper pointRulesMapper;
    private final UserMapper userMapper;
    private final PointsLogMapper pointsLogMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void exchangePoints(Integer steps, Long userId) {
        if (steps == null || steps <= 0) {
            throw new RuntimeException("步数不合法");
        }

        // 从数据库查询激活的积分兑换规则
        List<PointRules> activeRules = pointRulesMapper.selectList(
            new LambdaQueryWrapper<PointRules>()
                .eq(PointRules::getIsActive, PointRules_Status.ENABLE)
                .orderByAsc(PointRules::getStepsRequired)
        );

        if (activeRules == null || activeRules.isEmpty()) {
            // 如果没有配置规则，使用默认规则 1000:1
            log.warn("未找到积分兑换规则，使用默认规则 1000:1");
            int earnedPoints = steps / 1000;
            processPointsExchange(steps, earnedPoints, userId);
        } else {
            // 根据规则计算可兑换的积分
            int totalEarnedPoints = 0;
            int remainingSteps = steps;

            for (PointRules rule : activeRules) {
                if (remainingSteps < rule.getStepsRequired()) {
                    continue;
                }

                // 计算当前规则可以兑换多少次
                int exchangeCount = remainingSteps / rule.getStepsRequired();
                int earnedPoints = exchangeCount * rule.getPointsAwarded();
                int usedSteps = exchangeCount * rule.getStepsRequired();

                totalEarnedPoints += earnedPoints;
                remainingSteps -= usedSteps;

                log.info("应用规则: {}, 需要步数: {}, 获得积分: {}, 兑换次数: {}", 
                    rule.getRuleName(), rule.getStepsRequired(), rule.getPointsAwarded(), exchangeCount);
            }

            if (totalEarnedPoints == 0) {
                throw new RuntimeException("步数不足，无法兑换积分");
            }

            log.info("用户 {} 兑换步数: {}, 获得积分: {}, 剩余步数: {}", 
                userId, steps, totalEarnedPoints, remainingSteps);

            processPointsExchange(steps, totalEarnedPoints, userId);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void exchangePointsWithCalculatedPoints(Integer steps, Integer earnedPoints, Long userId) {
        if (steps == null || steps <= 0) {
            throw new RuntimeException("步数不合法");
        }
        if (earnedPoints == null || earnedPoints <= 0) {
            throw new RuntimeException("积分不合法");
        }
        
        log.info("用户 {} 使用指定积分兑换 - 步数: {}, 积分: {}", userId, steps, earnedPoints);
        processPointsExchange(steps, earnedPoints, userId);
    }

    /**
     * 处理积分兑换的核心逻辑
     */
    private void processPointsExchange(int usedSteps, int earnedPoints, Long userId) {
        log.info("========== 开始处理积分兑换 ==========");
        log.info("用户ID: {}, 使用步数: {}, 获得积分: {}", userId, usedSteps, earnedPoints);
        
        // 1. 查询并更新用户表中的剩余步数和积分
        User user = userMapper.selectById(userId);
        if (user == null) {
            log.error("用户不存在: {}", userId);
            throw new RuntimeException("用户不存在");
        }
        
        log.info("查询到的用户信息 - ID: {}, 用户名: {}, 当前剩余步数: {}, 当前总积分: {}",
            user.getId(), user.getUsername(), user.getRemainingStep(), user.getTotalPoints());
        
        // 计算新的剩余步数 = 当前剩余步数 - 使用的步数
        int currentRemainingSteps = user.getRemainingStep() != null ? user.getRemainingStep() : 0;
        int newRemainingSteps = currentRemainingSteps - usedSteps;
        
        log.info("计算新剩余步数: {} - {} = {}", currentRemainingSteps, usedSteps, newRemainingSteps);
        
        if (newRemainingSteps < 0) {
            log.error("剩余步数不足: 当前{}, 需要{}", currentRemainingSteps, usedSteps);
            throw new RuntimeException("剩余步数不足，无法兑换");
        }
        
        // 计算新的总积分 = 当前总积分 + 获得的积分
        int currentTotalPoints = user.getTotalPoints() != null ? user.getTotalPoints() : 0;
        int newTotalPoints = currentTotalPoints + earnedPoints;
        
        log.info("计算新总积分: {} + {} = {}", currentTotalPoints, earnedPoints, newTotalPoints);
        
        // 使用 UpdateWrapper 显式更新字段，确保数据库真正执行 UPDATE
        com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User> updateWrapper = 
            new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<>();
        updateWrapper.eq("id", userId)
                    .set("remaining_step", newRemainingSteps)
                    .set("total_points", newTotalPoints);
        
        log.info("准备更新数据库 - 用户ID: {}, 新剩余步数: {}, 新总积分: {}", userId, newRemainingSteps, newTotalPoints);
        
        int updateCount = userMapper.update(null, updateWrapper);
        
        log.info("数据库更新结果 - 影响行数: {}", updateCount);
        
        if (updateCount == 0) {
            log.error("数据库更新失败！影响行数为0");
            throw new RuntimeException("数据库更新失败");
        }
        
        log.info("更新用户 {} 的剩余步数: {} -> {}, 总积分: {} -> {}", 
            userId, currentRemainingSteps, newRemainingSteps, currentTotalPoints, newTotalPoints);
        
        // 验证更新是否成功
        User updatedUser = userMapper.selectById(userId);
        log.info("验证更新 - 用户ID: {}, 剩余步数: {}, 总积分: {}",
            updatedUser.getId(), updatedUser.getRemainingStep(), updatedUser.getTotalPoints());
        
        if (!updatedUser.getRemainingStep().equals(newRemainingSteps)) {
            log.error("验证失败！期望剩余步数: {}, 实际: {}", newRemainingSteps, updatedUser.getRemainingStep());
            throw new RuntimeException("数据验证失败");
        }
        
        log.info("========== 积分兑换处理完成 ==========");
        
        // 2. 创建积分兑换日志记录
        PointsLog pointsLog = new PointsLog();
        pointsLog.setUserId(userId);
        pointsLog.setBeforeStep(currentRemainingSteps);  // 兑换前的步数
        pointsLog.setAfterStep(newRemainingSteps);       // 兑换后的步数
        pointsLog.setPointsAmount(earnedPoints);         // 获得的积分
        pointsLog.setCreateTime(LocalDateTime.now());    // 兑换时间
        
        pointsLogMapper.insert(pointsLog);
        log.info("✅ 创建积分兑换日志 - 用户: {}, 消耗步数: {}, 获得积分: {}, 日志ID: {}",
            userId, usedSteps, earnedPoints, pointsLog.getId());
        
        log.info("========== 积分兑换处理完成 ==========");
    }

    @Override
    public com.hssp.model.user.po.User getUserById(Long userId) {
        return userMapper.selectById(userId);
    }
}
