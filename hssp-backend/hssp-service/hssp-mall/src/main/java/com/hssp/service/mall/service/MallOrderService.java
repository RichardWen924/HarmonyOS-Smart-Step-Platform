package com.hssp.service.mall.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.po.MallOrder;

public interface MallOrderService extends IService<MallOrder> {
    void exchangeOrder(Long goodsId, Long userId);
}
