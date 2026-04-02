package com.hssp.service.mall.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.po.UserPoints;

public interface UserPointsService extends IService<UserPoints> {
    void exchangePoints(Integer steps, Long userId);
}
