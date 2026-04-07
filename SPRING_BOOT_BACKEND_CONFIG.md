# 🔗 Spring Boot后端连接配置指南

## ✅ 前端配置已完成

### AppConfig.ets 配置
```typescript
// API 基础地址 - 连接到Spring Boot后端
baseUrl: string = 'http://localhost:8080/api'

// 关闭Mock模式，使用真实后端
enableMock: boolean = false
```

### JWT Token处理
- ✅ Bearer Token认证已配置
- ✅ Token自动添加到请求头
- ✅ Token过期自动处理

## 🔧 Spring Boot后端配置要求

### 1. 基础Spring Boot配置

#### application.yml/properties
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/step_platform
    username: root
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true

# JWT配置
jwt:
  secret: your-jwt-secret-key
  expiration: 7200 # 2小时
```

### 2. CORS配置（关键）

#### CorsConfig.java
```java
@Configuration
public class CorsConfig {
    
    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // 允许所有来源（生产环境应限制）
        config.addAllowedOrigin("*");
        
        // 允许的HTTP方法
        config.addAllowedMethod("GET");
        config.addAllowedMethod("POST");
        config.addAllowedMethod("PUT");
        config.addAllowedMethod("DELETE");
        config.addAllowedMethod("OPTIONS");
        
        // 允许的请求头
        config.addAllowedHeader("*");
        
        // 允许携带认证信息
        config.setAllowCredentials(true);
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

### 3. 安全配置

#### SecurityConfig.java
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors().and()
            .csrf().disable()
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }
}
```

### 4. API端点要求

#### 认证相关端点
```java
@RestController
@RequestMapping("/auth")
public class AuthController {
    
    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody LoginRequest request) {
        // 实现登录逻辑
    }
    
    @PostMapping("/login-by-code")
    public ApiResponse<LoginResponse> loginByCode(@RequestBody LoginRequest request) {
        // 验证码登录
    }
    
    @PostMapping("/register")
    public ApiResponse<LoginResponse> register(@RequestBody RegisterRequest request) {
        // 用户注册
    }
    
    @PostMapping("/send-code")
    public ApiResponse<Void> sendVerificationCode(@RequestBody VerificationRequest request) {
        // 发送验证码
    }
}
```

#### 响应格式
```java
public class ApiResponse<T> {
    private int code;        // 1=成功, 其他=错误
    private String message;  // 响应消息
    private T data;          // 响应数据
    
    // 构造函数、getter、setter
}
```

## 🚀 快速启动Spring Boot后端

### 1. 创建基础项目结构
```
backend/
├── src/main/java/com/example/backend/
│   ├── config/          # 配置类
│   ├── controller/      # 控制器
│   ├── service/         # 服务层
│   ├── repository/      # 数据访问层
│   ├── entity/          # 实体类
│   ├── dto/            # 数据传输对象
│   └── security/        # 安全相关
├── src/main/resources/
│   ├── application.yml
│   └── static/
└── pom.xml
```

### 2. 基础依赖 (pom.xml)
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.11.5</version>
    </dependency>
</dependencies>
```

### 3. 启动命令
```bash
# 编译并运行
mvn spring-boot:run

# 或打包后运行
mvn clean package
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

## 🔍 连接测试

### 1. 健康检查端点
确保后端提供健康检查端点：
```java
@RestController
public class HealthController {
    
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok", "timestamp", LocalDateTime.now().toString());
    }
}
```

### 2. 使用网络诊断工具
在HarmonyOS应用中：
1. 进入登录页面
2. 点击"测试后端连接"
3. 运行完整诊断

## 🐛 常见问题解决

### 问题1: CORS错误
**症状**: 请求被浏览器阻止
**解决**: 确保Spring Boot配置了正确的CORS设置

### 问题2: 连接拒绝
**症状**: 无法连接到localhost:8080
**解决**: 
- 检查Spring Boot是否正在运行
- 确认端口8080未被占用
- 如果是模拟器，使用10.0.2.2代替localhost

### 问题3: JWT认证失败
**症状**: 401 Unauthorized错误
**解决**: 
- 检查JWT Token格式
- 验证Token签名和过期时间
- 确认认证过滤器配置正确

### 问题4: 响应格式不匹配
**症状**: 前端无法解析响应
**解决**: 确保后端响应格式与前端ApiResponse一致

## 📱 HarmonyOS应用适配

### 特殊配置
如果应用运行在模拟器中，可能需要修改地址：
```typescript
// 模拟器访问本地主机的特殊地址
baseUrl: string = 'http://10.0.2.2:8080/api'
```

### 网络权限确认
确保module.json5中有网络权限：
```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

## 🎯 下一步行动

### 如果已有Spring Boot后端：
1. ✅ 确认API端点与前端匹配
2. ✅ 配置CORS设置
3. ✅ 启动后端服务
4. 🔄 测试连接

### 如果需要创建后端：
1. 🔄 按照上述指南创建Spring Boot项目
2. 🔄 实现必要的API端点
3. 🔄 配置数据库和JWT
4. 🔄 测试集成

---

💡 **提示**: 前端配置已完成，现在需要确保Spring Boot后端服务正在运行并配置正确。