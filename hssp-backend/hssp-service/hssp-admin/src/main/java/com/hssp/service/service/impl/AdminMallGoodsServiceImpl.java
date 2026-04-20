package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.mapper.MallGoodsMapper;
import com.hssp.service.service.AdminMallGoodsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.io.Serializable;
import java.util.List;

@Service
@Slf4j
public class AdminMallGoodsServiceImpl extends ServiceImpl<MallGoodsMapper, MallGoods> implements AdminMallGoodsService {

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    private static final String CACHE_KEY = "MALL:GOODS:LIST";

    @Override
    public void changeStatus(Long id, Integer status) {
        MallGoods goods = baseMapper.selectById(id);
        if (goods == null) {
            throw new RuntimeException("商品不存在");
        }
        goods.setIsDeleted(status);
        baseMapper.updateById(goods);
        refreshGoodsCache();
    }

    @Override
    public List<MallGoods> listAll() {
        return baseMapper.selectList(null);
    }

    @Override
    public Page<MallGoods> pageAll(int page, int size) {
        return baseMapper.selectPage(new Page<>(page, size), null);
    }

    @Override
    public MallGoods getGoodsById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public void refreshGoodsCache() {
        stringRedisTemplate.delete(CACHE_KEY);
    }

    @Override
    public boolean save(MallGoods entity) {
        boolean result = super.save(entity);
        if (result) {
            refreshGoodsCache();
        }
        return result;
    }

    @Override
    public boolean updateById(MallGoods entity) {
        boolean result = super.updateById(entity);
        if (result) {
            refreshGoodsCache();
        }
        return result;
    }

    @Override
    public boolean removeById(Serializable id) {
        boolean result = super.removeById(id);
        if (result) {
            refreshGoodsCache();
        }
        return result;
    }
}
