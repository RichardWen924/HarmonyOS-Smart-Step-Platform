package com.hssp.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HsspApplication {
    public static void main(String[] args) {
        SpringApplication.run(HsspApplication.class, args);
        System.out.println("====== HSSP Service started successfully ======");
    }
}
