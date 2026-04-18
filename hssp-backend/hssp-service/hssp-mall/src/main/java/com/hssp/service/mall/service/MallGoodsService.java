package com.hssp.service.mall.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.po.MallGoods;
import java.util.List;

public interface MallGoodsService extends IService<MallGoods> {
    void refreshGoodsCache();

    void changeStatus(Long id, Integer status);

    List<MallGoods> listAll();

    Page<MallGoods> page(int page, int size);

    Page<MallGoods> pageAll(int page, int size);

    MallGoods getGoodsById(Long id);
}
