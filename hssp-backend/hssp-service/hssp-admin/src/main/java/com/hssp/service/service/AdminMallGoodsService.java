package com.hssp.service.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.mall.po.MallGoods;
import java.util.List;

public interface AdminMallGoodsService extends IService<MallGoods> {
    void changeStatus(Long id, Integer status);
    List<MallGoods> listAll();
    Page<MallGoods> pageAll(int page, int size);
    MallGoods getGoodsById(Long id);
    void refreshGoodsCache();
}
