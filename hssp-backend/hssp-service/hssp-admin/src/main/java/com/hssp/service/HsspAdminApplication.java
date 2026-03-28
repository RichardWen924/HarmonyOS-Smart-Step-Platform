package com.hssp.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

//@SpringBootApplication
@SpringBootApplication(scanBasePackages = "com.hssp")
public class HsspAdminApplication {

    public static void main(String[] args) {
        SpringApplication.run(HsspAdminApplication.class, args);
    }

}
