package com.hssp.service;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.StringRedisTemplate;

@SpringBootTest
public class RedisTest {

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Test
    public void testRedisConnection() {
        String key = "test:connection";
        String value = "HSSP_REDIS_OK";

        // 写入测试数据
        stringRedisTemplate.opsForValue().set(key, value);

        // 读取测试数据
        String result = stringRedisTemplate.opsForValue().get(key);

        System.out.println("Redis 读取结果: " + result);

        // 断言验证
        Assertions.assertEquals(value, result);

        // 清理测试数据
        stringRedisTemplate.delete(key);
    }
}
