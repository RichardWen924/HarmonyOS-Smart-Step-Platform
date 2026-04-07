# 🔧 后端连接故障排除指南

## 🔍 问题症状
- 测试后端连接失败
- 测试登录API失败

## 🚨 立即诊断步骤

### 步骤1: 检查后端服务状态

#### 验证Spring Boot是否运行
```bash
# 检查端口8080是否被占用
netstat -ano | findstr :8080

# 如果端口被占用，查看占用进程
tasklist | findstr <PID>

# 或者使用PowerShell
Get-Process -Id (Get-NetTCPConnection -LocalPort 8080).OwningProcess
```

#### 检查Spring Boot日志
确保看到类似输出：
```
Started Application in 2.345 seconds (JVM running for 3.567)
Tomcat started on port(s): 8080 (http)
```

### 步骤2: 测试基础连接

#### 使用浏览器测试
访问以下地址：
- `http://localhost:8080` - 基础连接
- `http://localhost:8080/api` - API基础路径

**期望结果**: 应该看到Spring Boot的默认页面或404页面（说明服务在运行）

#### 使用curl测试
```bash
curl -v http://localhost:8080
curl -v http://localhost:8080/api
```

### 步骤3: 检查HarmonyOS应用配置

#### 确认AppConfig设置
```typescript
// 应该是这样的配置
baseUrl: string = 'http://localhost:8080/api'
enableMock: boolean = false
```

#### 检查网络权限
确保`module.json5`中有：
```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

## 🔧 常见问题解决方案

### 问题1: "Connection refused" 错误

**原因**: 后端服务未启动

**解决方案**:
```bash
# 启动Spring Boot
cd your-spring-boot-project
mvn spring-boot:run

# 或
java -jar target/your-app.jar
```

### 问题2: CORS错误

**症状**: 浏览器控制台显示CORS策略错误

**解决方案**: 在Spring Boot中添加CORS配置

```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        config.addAllowedOrigin("*");
        config.addAllowedMethod("*");
        config.addAllowedHeader("*");
        config.setAllowCredentials(true);
        
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

### 问题3: 模拟器环境连接问题

**症状**: 在模拟器中无法连接localhost

**解决方案**: 修改AppConfig为模拟器专用地址

```typescript
// 修改为模拟器地址
baseUrl: string = 'http://10.0.2.2:8080/api'
```

### 问题4: 防火墙阻止

**症状**: 连接超时或被拒绝

**解决方案**:
1. 检查Windows防火墙设置
2. 临时关闭防火墙测试
3. 添加端口8080的入站规则

```powershell
# 检查防火墙状态
Get-NetFirewallProfile

# 临时关闭防火墙（测试用）
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

## 📱 HarmonyOS应用调试

### 查看详细日志
在HarmonyOS应用中启用详细日志：
```typescript
// 确保AppConfig中
enableLog: boolean = true
```

### 使用网络诊断工具
1. 启动应用
2. 进入登录页面
3. 点击"测试后端连接"
4. 运行"完整诊断"

### 控制台错误分析
常见的错误信息及含义：

- **"NetworkError"**: 网络连接问题
- **"timeout"**: 请求超时
- **"404"**: 端点不存在
- **"401"**: 认证失败
- **"500"**: 服务器内部错误

## 🛠️ 快速修复脚本

### 创建测试端点（Spring Boot）
如果您的后端没有健康检查端点，可以添加：

```java
@RestController
public class HealthController {
    
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of(
            "status", "ok",
            "timestamp", LocalDateTime.now().toString(),
            "version", "1.0.0"
        );
    }
    
    @GetMapping("/api/health")
    public Map<String, String> apiHealth() {
        return health();
    }
}
```

### 修改HarmonyOS测试代码
如果测试仍然失败，可以临时修改测试逻辑：

```typescript
// 在TestBackendPage中，修改测试方法
private async testBackendConnection(): Promise<void> {
  // 先测试基础连接
  const baseUrl = AppConfig.baseUrl.replace('/api', '');
  // ... 测试逻辑
}
```

## 📋 逐步诊断流程

### 阶段1: 基础连接测试
1. [ ] Spring Boot服务是否运行？
2. [ ] 端口8080是否可用？
3. [ ] 防火墙是否阻止连接？

### 阶段2: API端点测试  
1. [ ] CORS配置是否正确？
2. [ ] API端点路径是否匹配？
3. [ ] 认证逻辑是否正确？

### 阶段3: HarmonyOS集成测试
1. [ ] 网络权限是否正确配置？
2. [ ] API客户端配置是否正确？
3. [ ] 错误处理逻辑是否完善？

## 🎯 紧急解决方案

### 方案A: 切换回Mock模式（临时）
```typescript
// 在AppConfig.ets中临时启用Mock
enableMock: boolean = true
```

### 方案B: 创建简单的测试后端
如果您还没有Spring Boot后端，可以快速创建一个：

```java
@SpringBootApplication
@RestController
public class SimpleBackend {
    
    public static void main(String[] args) {
        SpringApplication.run(SimpleBackend.class, args);
    }
    
    @GetMapping("/api/health")
    public String health() {
        return "{\"status\":\"ok\"}";
    }
    
    @PostMapping("/api/auth/login")
    public String login() {
        return "{\"code\":1,\"message\":\"登录成功\",\"data\":{\"token\":\"test-token\"}}";
    }
}
```

## 📞 获取更多帮助

### 提供诊断信息
如果问题持续存在，请提供：
1. Spring Boot启动日志
2. HarmonyOS控制台错误信息
3. 网络诊断工具的结果
4. 您的Spring Boot配置

### 联系技术支持
提供以下信息以便快速诊断：
- 操作系统版本
- HarmonyOS SDK版本
- Spring Boot版本
- 详细的错误日志

---

💡 **下一步建议**: 先使用浏览器测试 `http://localhost:8080` 是否能够访问，这将帮助确定问题是后端服务还是前端配置。