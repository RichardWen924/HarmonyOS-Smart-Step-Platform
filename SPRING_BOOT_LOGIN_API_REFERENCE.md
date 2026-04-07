# 🔐 Spring Boot登录API参考实现

## 📋 前端期望的API格式

### 请求格式
```json
POST /api/auth/login
Content-Type: application/json

{
  "account": "test@example.com",
  "password": "password123",
  "loginType": 1
}
```

### 响应格式
```json
{
  "code": 1,
  "message": "登录成功",
  "data": {
    "token": "jwt-token-string",
    "userInfo": {
      "id": 123,
      "username": "testuser",
      "email": "test@example.com",
      "nickname": "测试用户",
      "totalSteps": 15000,
      "totalPoints": 150,
      "remainingSteps": 8500
    },
    "expiresIn": 7200
  }
}
```

## 🛠️ Spring Boot实现参考

### 1. 控制器实现 (AuthController.java)

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return ApiResponse.success("登录成功", response);
        } catch (AuthenticationException e) {
            return ApiResponse.error(401, e.getMessage());
        }
    }
}
```

### 2. 请求/响应DTO

#### LoginRequest.java
```java
public class LoginRequest {
    private String account;
    private String password;
    private Integer loginType;
    
    // getters and setters
}
```

#### LoginResponse.java
```java
public class LoginResponse {
    private String token;
    private UserInfo userInfo;
    private Long expiresIn;
    
    // getters and setters
}
```

#### UserInfo.java
```java
public class UserInfo {
    private Long id;
    private String username;
    private String email;
    private String nickname;
    private Integer totalSteps;
    private Integer totalPoints;
    private Integer remainingSteps;
    
    // getters and setters
}
```

#### ApiResponse.java
```java
public class ApiResponse<T> {
    private Integer code;
    private String message;
    private T data;
    
    public static <T> ApiResponse<T> success(String message, T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(1);
        response.setMessage(message);
        response.setData(data);
        return response;
    }
    
    public static <T> ApiResponse<T> error(Integer code, String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(code);
        response.setMessage(message);
        return response;
    }
    
    // getters and setters
}
```

### 3. 服务层实现 (AuthService.java)

```java
@Service
public class AuthService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    public LoginResponse login(LoginRequest request) {
        // 根据账号类型查找用户
        User user = userRepository.findByEmail(request.getAccount())
            .orElseThrow(() -> new AuthenticationException("用户不存在"));
        
        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new AuthenticationException("密码错误");
        }
        
        // 生成JWT Token
        String token = jwtTokenProvider.generateToken(user);
        
        // 构建用户信息
        UserInfo userInfo = new UserInfo();
        userInfo.setId(user.getId());
        userInfo.setUsername(user.getUsername());
        userInfo.setEmail(user.getEmail());
        userInfo.setNickname(user.getNickname());
        userInfo.setTotalSteps(user.getTotalSteps());
        userInfo.setTotalPoints(user.getTotalPoints());
        userInfo.setRemainingSteps(user.getRemainingSteps());
        
        // 构建响应
        LoginResponse response = new LoginResponse();
        response.setToken(token);
        response.setUserInfo(userInfo);
        response.setExpiresIn(7200L); // 2小时
        
        return response;
    }
}
```

### 4. JWT工具类 (JwtTokenProvider.java)

```java
@Component
public class JwtTokenProvider {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private Long jwtExpiration;
    
    public String generateToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration * 1000);
        
        return Jwts.builder()
                .setSubject(Long.toString(user.getId()))
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }
    
    public Long getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token)
                .getBody();
        
        return Long.parseLong(claims.getSubject());
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
}
```

### 5. 数据初始化 (创建测试用户)

```java
@Component
public class DataInitializer {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @EventListener
    public void onApplicationEvent(ContextRefreshedEvent event) {
        // 创建测试用户（如果不存在）
        if (!userRepository.findByEmail("test@example.com").isPresent()) {
            User testUser = new User();
            testUser.setEmail("test@example.com");
            testUser.setPassword(passwordEncoder.encode("password123"));
            testUser.setUsername("testuser");
            testUser.setNickname("测试用户");
            testUser.setTotalSteps(15000);
            testUser.setTotalPoints(150);
            testUser.setRemainingSteps(8500);
            
            userRepository.save(testUser);
            System.out.println("测试用户创建成功: test@example.com / password123");
        }
    }
}
```

## 🔧 快速测试端点

### 简单的测试控制器（临时方案）

如果您的后端还没有完整的认证系统，可以先创建一个简单的测试端点：

```java
@RestController
@RequestMapping("/api/auth")
public class TestAuthController {
    
    @PostMapping("/login")
    public Map<String, Object> testLogin(@RequestBody Map<String, Object> request) {
        String account = (String) request.get("account");
        String password = (String) request.get("password");
        
        // 简单的测试认证
        if ("test@example.com".equals(account) && "password123".equals(password)) {
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", 123);
            userInfo.put("username", "testuser");
            userInfo.put("email", "test@example.com");
            userInfo.put("nickname", "测试用户");
            userInfo.put("totalSteps", 15000);
            userInfo.put("totalPoints", 150);
            userInfo.put("remainingSteps", 8500);
            
            Map<String, Object> data = new HashMap<>();
            data.put("token", "test-jwt-token-123456");
            data.put("userInfo", userInfo);
            data.put("expiresIn", 7200);
            
            Map<String, Object> response = new HashMap<>();
            response.put("code", 1);
            response.put("message", "登录成功");
            response.put("data", data);
            
            return response;
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("code", 401);
            response.put("message", "账号或密码错误");
            return response;
        }
    }
}
```

## 🎯 诊断建议

### 请检查您的Spring Boot后端：

1. **是否有 `/api/auth/login` 端点？**
2. **请求格式是否匹配？**
3. **测试账号是否存在？**
4. **响应格式是否正确？**

### 使用Postman测试：

```http
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
  "account": "test@example.com",
  "password": "password123",
  "loginType": 1
}
```

**请告诉我Postman测试的结果**，这样我可以提供更精确的解决方案！