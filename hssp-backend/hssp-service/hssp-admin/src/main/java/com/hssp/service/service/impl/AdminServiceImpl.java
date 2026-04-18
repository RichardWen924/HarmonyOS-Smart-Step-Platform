package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.common.exception.BusinessException;
import com.hssp.common.utils.JwtUtils;
import com.hssp.model.admin.dto.RegisterDto;
import com.hssp.model.admin.po.Admin;
import com.hssp.model.admin.dto.LoginDto;
import com.hssp.model.admin.po.Admin;
import com.hssp.service.mapper.AdminMapper;
import com.hssp.service.service.AdminService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Objects;

@Service
@Slf4j
@RequiredArgsConstructor
public class AdminServiceImpl extends ServiceImpl<AdminMapper,Admin> implements AdminService {


    private static final String CODE_PREFIX = "EMAIL_CODE:";
    private static final String DEFAULT_PASSWORD = "123456";
    private final RedisTemplate<String, Object> redisTemplate;
    // 注入加密工具
    private final PasswordEncoder passwordEncoder;

    @Override
    public void register(RegisterDto registerDto) {
        boolean exist = lambdaQuery()
                .eq(Admin::getEmail, registerDto.getEmail())
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
            Admin admin = new Admin();
            admin.setEmail(registerDto.getEmail());
            admin.setUsername(registerDto.getEmail());
            // 密码加密
            //明文
            String rawPassword=DEFAULT_PASSWORD;
            //加密
            String encodedPassword = passwordEncoder.encode(rawPassword);

            log.info("加密密码{}", encodedPassword);

            admin.setPassword(encodedPassword);
            save(admin);
            redisTemplate.delete(CODE_PREFIX + registerDto.getEmail());
        }
    }

    /*
     * 管理员登录
     * @param loginDto 登录参数,目前支持用户名/邮箱加密码登录
     * @return 登录成功返回令牌，失败返回null
     */
    @Override
    public String login(LoginDto loginDto) {
        String input = loginDto.getUsername();
        String password = loginDto.getPassword();

        if (Objects.isNull(password)) {
            throw new BusinessException("密码不能为空");
        }

        if (Objects.isNull(input)) {
            throw new BusinessException("邮箱/用户名不能为空");
        }

        Admin admin = lambdaQuery()
                .eq(Admin::getUsername, input)
                .or()
                .eq(Admin::getEmail, input)
                .one();
        if (Objects.isNull(admin)) {
            throw new BusinessException("用户名/邮箱不存在");
        }

        boolean rightPassword = passwordEncoder.matches(password, admin.getPassword());
        if (!rightPassword) {
            throw new BusinessException("用户名或密码错误");
        }
        // 登录成功，生成令牌
        return JwtUtils.createToken(admin.getId());
    }

//    @Override
//    public String login(LoginDto loginDto) {
//        String Username = loginDto.getUsername();
//        String password = loginDto.getPassword();
//        String email = loginDto.getEmail();
//        String verification = loginDto.getVerification();
//        //验证码不为空，即选择了邮箱加验证码的登录方式
//        if(verification!=null){
//            if(email==null){
//                throw new BusinessException("邮箱不能为空");
//            }
//            log.info("邮箱+验证码登录");
//            String cacheVerification = Objects.requireNonNull(redisTemplate.opsForValue().get(CODE_PREFIX + email)).toString();
//            if(!cacheVerification.equals(verification)){
//                throw new BusinessException("验证码错误");
//            }
//            Admin admin=lambdaQuery()
//                    .eq(Admin::getEmail, email)
//                    .one();
//            if(admin==null){
//                throw new BusinessException("邮箱不存在");
//            }
//            // 登录成功，生成令牌
//            String token= JwtUtils.createToken(admin.getId());
//            return token;
//        }
//        //验证码为空，即选择了用户名/邮箱加密码的登录方式
//        else{
//            if(Username!=null){
//                String encodePassword = passwordEncoder.encode(password);
//                log.info("用户名+密码登录");
//                Admin admin=lambdaQuery()
//                        .eq(Admin::getUsername, Username)
//                        .one();
//                boolean rightPassword=passwordEncoder.matches(password, admin.getPassword());
//                if(!rightPassword){
//                    throw new BusinessException("用户名或密码错误");
//                }
//                // 登录成功，生成令牌
//                String token= JwtUtils.createToken(admin.getId());
//                return token;
//            }
//            else if(email!=null){
//                String encodePassword = passwordEncoder.encode(password);
//                log.info("邮箱+密码登录");
//                Admin admin=lambdaQuery()
//                        .eq(Admin::getEmail, email)
//                        .one();
//                boolean rightPassword=passwordEncoder.matches(password, admin.getPassword());
//                if(!rightPassword){
//                    throw new BusinessException("用户名或密码错误");
//                }
//                // 登录成功，生成令牌
//                String token= JwtUtils.createToken(admin.getId());
//                return token;
//            }
//            else{
//                throw new BusinessException("用户名/邮箱不能为空");
//            }
//
//        }
//    }
}
