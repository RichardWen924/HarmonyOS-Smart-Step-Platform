package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.common.context.UserContext;
import com.hssp.common.exception.BusinessException;
import com.hssp.common.utils.JwtUtils;
import com.hssp.model.user.dto.ChangeInfoDto;
import com.hssp.model.user.dto.ChangePasswordDto;
import com.hssp.model.user.dto.LoginDto;
import com.hssp.model.user.dto.RegisterDto;
import com.hssp.model.user.po.User;
import com.hssp.service.mapper.UserMapper;
import com.hssp.service.service.IUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Objects;


@Service
@Slf4j
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements IUserService {
    private static final String CODE_PREFIX = "EMAIL_CODE:";
    private static final String DEFAULT_PASSWORD = "123456";
    private final RedisTemplate<String, Object> redisTemplate;
    // 注入加密工具
    private final PasswordEncoder passwordEncoder;


//    @Autowired
//    private StringRedisTemplate redisTemplate;
    @Override
    public void register(RegisterDto registerDto) {
        boolean exist = lambdaQuery()
                .eq(User::getEmail, registerDto.getEmail())
                .one() != null;
        if (exist) {
            throw new BusinessException("邮箱已存在");
        }
        String cacheVerification = Objects.requireNonNull(redisTemplate.opsForValue().get(CODE_PREFIX + registerDto.getEmail())).toString();
        log.info("cacheVerification: {}", cacheVerification);
        if (!cacheVerification.equals(registerDto.getVerification())) {
            throw new BusinessException("验证码错误");
        } else {
            // 注册用户
            User user = new User();
            user.setEmail(registerDto.getEmail());
            user.setUsername(registerDto.getEmail());
            // 密码加密
            //明文
            String rawPassword=DEFAULT_PASSWORD;
            //加密
            String encodedPassword = passwordEncoder.encode(rawPassword);

            log.info("加密密码{}", encodedPassword);

            user.setPassword(encodedPassword);
            save(user);
            redisTemplate.delete(CODE_PREFIX + registerDto.getEmail());
        }
    }

    @Override
    public String login(LoginDto loginDto) {
        String Username = loginDto.getUsername();
        String password = loginDto.getPassword();
        String email = loginDto.getEmail();
        String verification = loginDto.getVerification();
        //验证码不为空，即选择了邮箱加验证码的登录方式
        if(verification!=null){
            if(email==null){
               throw new BusinessException("邮箱不能为空");
            }
            log.info("邮箱+验证码登录");
            String cacheVerification = Objects.requireNonNull(redisTemplate.opsForValue().get(CODE_PREFIX + email)).toString();
            if(!cacheVerification.equals(verification)){
               throw new BusinessException("验证码错误");
            }
            User user=lambdaQuery()
                    .eq(User::getEmail, email)
                    .one();
            if(user==null){
                throw new BusinessException("邮箱不存在");
            }
            // 登录成功，生成令牌
            String token= JwtUtils.createToken(user.getId());
            return token;
        }
        //验证码为空，即选择了用户名/邮箱加密码的登录方式
        else{
            if(Username!=null){
                String encodePassword = passwordEncoder.encode(password);
                log.info("用户名+密码登录");
                User user=lambdaQuery()
                        .eq(User::getUsername, Username)
                        .one();
                boolean rightPassword=passwordEncoder.matches(password, user.getPassword());
                if(!rightPassword){
                    throw new BusinessException("用户名或密码错误");
                }
                // 登录成功，生成令牌
                String token= JwtUtils.createToken(user.getId());
                return token;
            }
            else if(email!=null){
                String encodePassword = passwordEncoder.encode(password);
                log.info("邮箱+密码登录");
                User user=lambdaQuery()
                        .eq(User::getEmail, email)
                        .one();
                boolean rightPassword=passwordEncoder.matches(password, user.getPassword());
                if(!rightPassword){
                    throw new BusinessException("用户名或密码错误");
                }
                // 登录成功，生成令牌
                String token= JwtUtils.createToken(user.getId());
                return token;
            }
            else{
                throw new BusinessException("用户名/邮箱不能为空");
            }

        }
    }

    @Override
    public void update(ChangeInfoDto changeInfoDto) {
        Long userId= UserContext.getUserId();
        boolean exist = lambdaQuery()
                .eq(User::getId, userId)
                .one() != null;
        if(!exist){
            throw new BusinessException("用户不存在");
        }
        User user=new User();
        user.setId(userId);
        BeanUtils.copyProperties(changeInfoDto,user);
        updateById(user);
    }

    @Override
    public void updatePassword(ChangePasswordDto changePasswordDto) {
        String encodePassword = passwordEncoder.encode(changePasswordDto.getOldPassword());
        Long userId= UserContext.getUserId();
        User user=lambdaQuery()
                .eq(User::getId, userId)
                .one();
        if(!passwordEncoder.matches(changePasswordDto.getOldPassword(), user.getPassword())){
            throw new BusinessException("旧密码错误");
        }
        user.setId(userId);
        user.setPassword(encodePassword);
        updateById(user);
    }

    @Override
    public Integer getPoints() {
        Long userId= UserContext.getUserId();
        Integer points=lambdaQuery()
                .eq(User::getId, userId)
                .one()
                .getTotalPoints();
        return points;
    }
}
