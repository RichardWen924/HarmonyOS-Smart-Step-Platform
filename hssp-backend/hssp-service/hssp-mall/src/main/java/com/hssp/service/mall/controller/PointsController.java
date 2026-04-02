package com.hssp.service.mall.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.dto.ExchangePointsDto;
import com.hssp.service.mall.service.UserPointsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/points")
public class PointsController {

    @Autowired
    private UserPointsService userPointsService;

    // TODO: 之后迁移至 Token 获取 UserId
    private Long mockUserId = 1L;

    @PostMapping("/exchange")
    public Result exchange(@RequestBody ExchangePointsDto dto) {
        if (dto.getSteps() == null || dto.getSteps() <= 0) {
            return Result.error("步数不合法");
        }
        
        try {
            userPointsService.exchangePoints(dto.getSteps(), mockUserId);
            return Result.success("兑换积分成功", null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
