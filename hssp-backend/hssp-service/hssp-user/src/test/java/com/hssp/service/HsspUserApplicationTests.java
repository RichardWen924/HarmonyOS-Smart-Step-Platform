package com.hssp.service;

import com.hssp.service.service.MailService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.client.RestTemplate;

@SpringBootTest
class HsspUserApplicationTests {

    @Autowired
    private StringRedisTemplate redisTemplate;
    @Test
    void contextLoads() {
    }

    @Test
    void testRedis(){
        redisTemplate.opsForValue().set("test", "hello");


    }

}
