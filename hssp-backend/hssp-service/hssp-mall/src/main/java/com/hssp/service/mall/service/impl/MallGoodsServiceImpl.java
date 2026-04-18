package com.hssp.service.mall.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.mall.mapper.MallGoodsMapper;
import com.hssp.service.mall.service.MallGoodsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class MallGoodsServiceImpl extends ServiceImpl<MallGoodsMapper, MallGoods> implements MallGoodsService {

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    private static final String CACHE_KEY = "MALL:GOODS:LIST";
    private static final long CACHE_TTL = 10; // 10 minutes

    @Override
    public List<MallGoods> list() {
        // 1. 从缓存获取
        String cacheData = stringRedisTemplate.opsForValue().get(CACHE_KEY);
        if (StringUtils.hasText(cacheData)) {
            // 防止缓存穿透的空对象标识
            if ("EMPTY".equals(cacheData)) {
                return Collections.emptyList();
            }
            try {
                return objectMapper.readValue(cacheData, new TypeReference<List<MallGoods>>() {});
            } catch (JsonProcessingException e) {
                log.error("解析商品列表缓存失败", e);
            }
        }

        // 2. 查数据库 (只查询上架状态的商品 isDeleted = 0)
        List<MallGoods> goodsList = baseMapper.selectList(new LambdaQueryWrapper<MallGoods>()
                .eq(MallGoods::getIsDeleted, 0));

        // 3. 回刷缓存
        if (goodsList == null || goodsList.isEmpty()) {
            // 防止缓存穿透：缓存空结果，过期时间设短一点，比如 1 分钟
            stringRedisTemplate.opsForValue().set(CACHE_KEY, "EMPTY", 1, TimeUnit.MINUTES);
        } else {
            try {
                String jsonStr = objectMapper.writeValueAsString(goodsList);
                stringRedisTemplate.opsForValue().set(CACHE_KEY, jsonStr, CACHE_TTL, TimeUnit.MINUTES);
            } catch (JsonProcessingException e) {
                log.error("将商品列表写入缓存失败", e);
            }
        }

        return goodsList;
    }

    @Override
    public void refreshGoodsCache() {
        // 删除缓存
        stringRedisTemplate.delete(CACHE_KEY);
        // 立即触发同步
        this.list();
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
    public Page<MallGoods> page(int page, int size) {
        return baseMapper.selectPage(new Page<>(page, size),
                new LambdaQueryWrapper<MallGoods>().eq(MallGoods::getIsDeleted, 0));
    }

    @Override
    public Page<MallGoods> pageAll(int page, int size) {
        return baseMapper.selectPage(new Page<>(page, size), null);
    }

    @Override
    public MallGoods getGoodsById(Long id) {
        return baseMapper.selectById(id);
    }
}
