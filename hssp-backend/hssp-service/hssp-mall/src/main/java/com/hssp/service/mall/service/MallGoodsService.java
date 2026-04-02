package com.hssp.service.mall.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.po.MallGoods;

public interface MallGoodsService extends IService<MallGoods> {
    void refreshGoodsCache();
}
