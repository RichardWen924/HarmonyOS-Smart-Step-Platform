package com.hssp.service.mall.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hssp.common.admin.PointRules_Status;
import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.admin.po.PointRules;
import com.hssp.model.mall.dto.ExchangePointsDto;
import com.hssp.service.mall.mapper.PointRulesMapper;
import com.hssp.service.mall.service.UserPointsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/")
@RequiredArgsConstructor
public class PointsController {

    private final UserPointsService userPointsService;
    private final PointRulesMapper pointRulesMapper;

    /**
     * 获取所有启用的积分兑换规则
     */
    @GetMapping("/rules")
    public Result getPointRules() {
        List<PointRules> rules = pointRulesMapper.selectList(
            new LambdaQueryWrapper<PointRules>()
                .eq(PointRules::getIsActive, PointRules_Status.ENABLE)
                .orderByAsc(PointRules::getStepsRequired)
        );
        return Result.success(rules);
    }

    /**
     * 预览兑换结果（不实际执行兑换）
     */
    @PostMapping("/preview")
    public Result previewExchange(@RequestBody ExchangePointsDto dto) {
        if (dto.getSteps() == null || dto.getSteps() <= 0) {
            return Result.error("步数不合法");
        }
        
        try {
            // 从数据库查询激活的积分兑换规则
            List<PointRules> activeRules = pointRulesMapper.selectList(
                new LambdaQueryWrapper<PointRules>()
                    .eq(PointRules::getIsActive, PointRules_Status.ENABLE)
                    .orderByAsc(PointRules::getStepsRequired)
            );

            int totalEarnedPoints = 0;
            int remainingSteps = dto.getSteps();
            java.util.List<java.util.Map<String, Object>> ruleDetails = new java.util.ArrayList<>();

            if (activeRules == null || activeRules.isEmpty()) {
                // 默认规则
                totalEarnedPoints = dto.getSteps() / 1000;
                remainingSteps = dto.getSteps() % 1000;
                java.util.Map<String, Object> defaultRule = new java.util.HashMap<>();
                defaultRule.put("ruleName", "默认规则");
                defaultRule.put("stepsRequired", 1000);
                defaultRule.put("pointsAwarded", 1);
                defaultRule.put("exchangeCount", dto.getSteps() / 1000);
                defaultRule.put("earnedPoints", totalEarnedPoints);
                ruleDetails.add(defaultRule);
            } else {
                for (PointRules rule : activeRules) {
                    if (remainingSteps < rule.getStepsRequired()) {
                        continue;
                    }

                    int exchangeCount = remainingSteps / rule.getStepsRequired();
                    int earnedPoints = exchangeCount * rule.getPointsAwarded();
                    int usedSteps = exchangeCount * rule.getStepsRequired();

                    totalEarnedPoints += earnedPoints;
                    remainingSteps -= usedSteps;

                    java.util.Map<String, Object> detail = new java.util.HashMap<>();
                    detail.put("ruleName", rule.getRuleName());
                    detail.put("stepsRequired", rule.getStepsRequired());
                    detail.put("pointsAwarded", rule.getPointsAwarded());
                    detail.put("exchangeCount", exchangeCount);
                    detail.put("earnedPoints", earnedPoints);
                    ruleDetails.add(detail);
                }
            }

            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("inputSteps", dto.getSteps());
            result.put("totalEarnedPoints", totalEarnedPoints);
            result.put("remainingSteps", remainingSteps);
            result.put("ruleDetails", ruleDetails);

            return Result.success(result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 步数兑换积分
     */
    @PostMapping("/exchange")
    public Result exchange(@RequestBody ExchangePointsDto dto) {
        if (dto.getSteps() == null || dto.getSteps() <= 0) {
            return Result.error("步数不合法");
        }
        
        try {
            // 从 Token 中获取用户ID
            Long userId = UserContext.getUserId();
            
            // 预览兑换结果，计算获得的积分
            List<PointRules> activeRules = pointRulesMapper.selectList(
                new LambdaQueryWrapper<PointRules>()
                    .eq(PointRules::getIsActive, PointRules_Status.ENABLE)
                    .orderByAsc(PointRules::getStepsRequired)
            );
            
            int earnedPoints = 0;
            if (activeRules == null || activeRules.isEmpty()) {
                earnedPoints = dto.getSteps() / 1000;
            } else {
                int remainingSteps = dto.getSteps();
                for (PointRules rule : activeRules) {
                    if (remainingSteps < rule.getStepsRequired()) {
                        continue;
                    }
                    int exchangeCount = remainingSteps / rule.getStepsRequired();
                    earnedPoints += exchangeCount * rule.getPointsAwarded();
                    remainingSteps -= exchangeCount * rule.getStepsRequired();
                }
            }
            
            // 执行兑换
            userPointsService.exchangePoints(dto.getSteps(), userId);
            
            // 查询兑换后的用户信息
            com.hssp.model.user.po.User user = userPointsService.getUserById(userId);
            
            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("exchangedSteps", dto.getSteps());
            result.put("gainedPoints", earnedPoints);
            result.put("remainingSteps", user != null ? user.getRemainingStep() : 0);
            result.put("totalPoints", user != null ? user.getTotalPoints() : 0);  // 使用 User 表的 totalPoints
            result.put("timestamp", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
            
            return Result.success("兑换积分成功", result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
