package com.hssp.service.mall.service;

public interface UserPointsService {
    /**
     * 兑换积分（自动计算）
     */
    void exchangePoints(Integer steps, Long userId);
    
    /**
     * 兑换积分（使用指定的积分数）
     * @param steps 使用的步数
     * @param earnedPoints 获得的积分
     * @param userId 用户ID
     */
    void exchangePointsWithCalculatedPoints(Integer steps, Integer earnedPoints, Long userId);
    
    com.hssp.model.user.po.User getUserById(Long userId);
}
