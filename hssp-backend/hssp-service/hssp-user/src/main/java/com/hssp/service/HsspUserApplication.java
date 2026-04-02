package com.hssp.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = "com.hssp")
@EnableDiscoveryClient
public class HsspUserApplication {

    public static void main(String[] args) {
        SpringApplication.run(HsspUserApplication.class, args);
    }

}
