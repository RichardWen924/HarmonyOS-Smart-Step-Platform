package com.hssp.service.mall.service;

public interface UserPointsService {
    void exchangePoints(Integer steps, Long userId);
    
    com.hssp.model.user.po.User getUserById(Long userId);
}
