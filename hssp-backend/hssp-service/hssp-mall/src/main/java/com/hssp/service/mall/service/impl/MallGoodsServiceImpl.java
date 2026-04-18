package com.hssp.service.mall.service.impl;

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
                log.info("商品列表缓存命中（空）");
                return Collections.emptyList();
            }
            try {
                List<MallGoods> cachedList = objectMapper.readValue(cacheData, new TypeReference<List<MallGoods>>() {});
                log.info("商品列表缓存命中，共 {} 个商品", cachedList.size());
                if (!cachedList.isEmpty()) {
                    log.info("第一个缓存商品: ID={}, 名称={}, 库存={}", 
                        cachedList.get(0).getId(), 
                        cachedList.get(0).getGoodsName(),
                        cachedList.get(0).getStock());
                }
                return cachedList;
            } catch (JsonProcessingException e) {
                log.error("解析商品列表缓存失败", e);
            }
        }

        // 2. 查数据库
        log.info("商品列表缓存未命中，查询数据库...");
        List<MallGoods> goodsList = baseMapper.selectList(null);
        log.info("从数据库查询到 {} 个商品", goodsList != null ? goodsList.size() : 0);
        if (goodsList != null && !goodsList.isEmpty()) {
            log.info("第一个数据库商品: ID={}, 名称={}, 库存={}", 
                goodsList.get(0).getId(), 
                goodsList.get(0).getGoodsName(),
                goodsList.get(0).getStock());
        }

        // 3. 回刷缓存
        if (goodsList == null || goodsList.isEmpty()) {
            // 防止缓存穿透：缓存空结果，过期时间设短一点，比如 1 分钟
            stringRedisTemplate.opsForValue().set(CACHE_KEY, "EMPTY", 1, TimeUnit.MINUTES);
            log.info("缓存空结果，TTL=1分钟");
        } else {
            try {
                String jsonStr = objectMapper.writeValueAsString(goodsList);
                stringRedisTemplate.opsForValue().set(CACHE_KEY, jsonStr, CACHE_TTL, TimeUnit.MINUTES);
                log.info("商品列表已缓存，TTL={} 分钟", CACHE_TTL);
            } catch (JsonProcessingException e) {
                log.error("将商品列表写入缓存失败", e);
            }
        }

        return goodsList;
    }

    @Override
    public void refreshGoodsCache() {
        // 删除缓存
        boolean deleted = stringRedisTemplate.delete(CACHE_KEY);
        log.info("清除商品缓存: {}", deleted ? "成功" : "缓存不存在");
        // 不立即重新加载，让下次查询时从数据库获取最新数据
    }
}
