package com.hssp.common.config;

import com.hssp.common.interceptor.LoginInterceptor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * WebMvc 配置 - 仅在 Servlet (MVC) 环境下加载。
 * 避免了在 WebFlux (Gateway) 环境下因缺少 WebMvcConfigurer 类而加载失败。
 */
@Configuration
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
public class WebMvcConfig {

    /**
     * 内部类隔离 WebMvcConfigurer 接口，确保网关启动时不会因类加载失败。
     */
    @Configuration
    static class MvcConfig implements WebMvcConfigurer {
        @Override
        public void addInterceptors(InterceptorRegistry registry) {
            registry.addInterceptor(new LoginInterceptor())
                    .addPathPatterns("/**")
                    .excludePathPatterns("/user/login",
                            "/user/register",
                            "/user/send-verification",
                            "/admin/login",
                            "/admin/register",
                            "/admin/send-verification",
                            "/error");
        }
    }
}