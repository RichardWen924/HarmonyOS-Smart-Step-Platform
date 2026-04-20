package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hssp.common.context.UserContext;
import com.hssp.common.exception.BusinessException;
import com.hssp.common.utils.JwtUtils;
import com.hssp.model.user.dto.ChangeInfoDto;
import com.hssp.model.user.dto.ChangePasswordDto;
import com.hssp.model.user.dto.LoginDto;
import com.hssp.model.user.dto.RegisterDto;
import com.hssp.model.user.dto.StepUploadDto;
import com.hssp.model.user.po.PointsLog;
import com.hssp.model.user.po.StepRecord;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.ExchangeRecordVo;
import com.hssp.model.user.vo.StepRecordVo;
import com.hssp.model.user.vo.StepStatisticsVo;
import com.hssp.model.user.vo.StepTrendVo;
import com.hssp.service.mapper.PointsLogMapper;
import com.hssp.service.mapper.StepRecordMapper;
import com.hssp.service.mapper.UserMapper;
import com.hssp.service.service.IUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;


@Service
@Slf4j
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements IUserService {
    private static final String CODE_PREFIX = "EMAIL_CODE:";
    private static final String DEFAULT_PASSWORD = "123456";
    private static final String DAILY_RANK_KEY_PREFIX = "hssp:rank:daily:";
    private static final String WEEKLY_RANK_KEY_PREFIX = "hssp:rank:week:";
    private static final String MONTHLY_RANK_KEY_PREFIX = "hssp:rank:month:";
    
    private final RedisTemplate<String, Object> redisTemplate;
    // 注入加密工具
    private final PasswordEncoder passwordEncoder;
    private final StepRecordMapper stepRecordMapper;
    private final PointsLogMapper pointsLogMapper;


//    @Autowired
//    private StringRedisTemplate redisTemplate;
    @Override
    public void register(RegisterDto registerDto) {
        log.info("📝 开始注册用户 - 邮箱: {}", registerDto.getEmail());
        
        // 1. 检查邮箱是否已存在
        boolean exist = lambdaQuery()
                .eq(User::getEmail, registerDto.getEmail())
                .one() != null;
        if (exist) {
            log.warn("❌ 注册失败 - 邮箱已存在: {}", registerDto.getEmail());
            throw new BusinessException("邮箱已存在");
        }
        
        // 2. 验证验证码
        String redisKey = CODE_PREFIX + registerDto.getEmail();
        Object cacheVerificationObj = redisTemplate.opsForValue().get(redisKey);
        
        if (cacheVerificationObj == null) {
            log.error("❌ 注册失败 - 验证码不存在或已过期 - 邮箱: {}, Redis Key: {}", 
                registerDto.getEmail(), redisKey);
            throw new BusinessException("验证码不存在或已过期，请重新获取");
        }
        
        String cacheVerification = cacheVerificationObj.toString();
        log.info("🔍 验证码验证 - 邮箱: {}, 用户输入: {}, Redis中的: {}", 
            registerDto.getEmail(), registerDto.getVerification(), cacheVerification);
        
        if (!cacheVerification.equals(registerDto.getVerification())) {
            log.error("❌ 注册失败 - 验证码错误 - 邮箱: {}", registerDto.getEmail());
            throw new BusinessException("验证码错误");
        }
        
        log.info("✅ 验证码验证通过 - 邮箱: {}", registerDto.getEmail());
        
        // 3. 创建用户
        User user = new User();
        user.setUsername(registerDto.getUsername());  // 使用注册时输入的用户名
        user.setEmail(registerDto.getEmail());
        user.setNickname(registerDto.getUsername());  // 昵称默认与用户名相同
        
        // 密码加密（使用用户输入的密码）
        String rawPassword = registerDto.getPassword();
        String encodedPassword = passwordEncoder.encode(rawPassword);
        log.info("🔐 密码加密完成");
        
        user.setPassword(encodedPassword);
        save(user);
        
        log.info("✅ 用户注册成功 - ID: {}, 邮箱: {}", user.getId(), user.getEmail());
        
        // 4. 删除Redis中的验证码（防止重复使用）
        redisTemplate.delete(redisKey);
        log.info("🗑️  已删除Redis中的验证码 - Key: {}", redisKey);
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
                log.info("用户名+密码登录");
                User user=lambdaQuery()
                        .eq(User::getUsername, Username)
                        .one();
                if(user == null){
                    throw new BusinessException("用户名或密码错误");
                }
                boolean rightPassword=passwordEncoder.matches(password, user.getPassword());
                if(!rightPassword){
                    throw new BusinessException("用户名或密码错误");
                }
                // 登录成功，生成令牌
                String token= JwtUtils.createToken(user.getId());
                return token;
            }
            else if(email!=null){
                log.info("邮箱+密码登录");
                User user=lambdaQuery()
                        .eq(User::getEmail, email)
                        .one();
                if(user == null){
                    throw new BusinessException("用户名或密码错误");
                }
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
    @Transactional(rollbackFor = Exception.class)
    public void updatePassword(ChangePasswordDto changePasswordDto) {
        Long userId= UserContext.getUserId();
        User user=lambdaQuery()
                .eq(User::getId, userId)
                .one();
        if(!passwordEncoder.matches(changePasswordDto.getOldPassword(), user.getPassword())){
            throw new BusinessException("旧密码错误");
        }
        // 对新密码进行加密
        String encodePassword = passwordEncoder.encode(changePasswordDto.getNewPassword());
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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void uploadSteps(StepUploadDto stepUploadDto) {
        Long userId = UserContext.getUserId();
        log.info("用户 {} 上传步数: {}", userId, stepUploadDto.getSteps());
        
        // 1. 确定日期
        LocalDate recordDate;
        if (stepUploadDto.getDate() != null && !stepUploadDto.getDate().isEmpty()) {
            recordDate = LocalDate.parse(stepUploadDto.getDate(), DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        } else {
            recordDate = LocalDate.now();
        }
        
        // 2. 查询是否已有该日期的记录
        StepRecord existingRecord = stepRecordMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .eq(StepRecord::getRecordDate, recordDate)
        );
        
        int todaySteps = stepUploadDto.getSteps();
        
        // 保存原始步数（用于计算差值）
        Integer previousTodaySteps = existingRecord != null ? existingRecord.getStepCount() : 0;
        
        if (existingRecord != null) {
            // 更新已有记录（取较大值）
            int maxSteps = Math.max(existingRecord.getStepCount(), todaySteps);
            existingRecord.setStepCount(maxSteps);
            existingRecord.setLastUploadTime(LocalDateTime.now());
            stepRecordMapper.updateById(existingRecord);
            todaySteps = maxSteps;
            log.info("更新步数记录，用户: {}, 日期: {}, 步数: {}", userId, recordDate, todaySteps);
        } else {
            // 创建新记录
            StepRecord newRecord = new StepRecord();
            newRecord.setUserId(userId);
            newRecord.setRecordDate(recordDate);
            newRecord.setStepCount(todaySteps);
            newRecord.setLastUploadTime(LocalDateTime.now());
            stepRecordMapper.insert(newRecord);
            log.info("创建步数记录，用户: {}, 日期: {}, 步数: {}", userId, recordDate, todaySteps);
        }
        
        // 3. 更新用户总步数和剩余步数
        // 重要：重新查询用户信息，避免使用缓存的对象导致数据污染
        User user = this.getOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<User>()
                .eq(User::getId, userId)
                .last("FOR UPDATE")  // 加锁防止并发问题
        );
        
        if (user != null) {
            log.info("上传前用户信息 - 用户: {}, 总步数: {}, 剩余步数: {}", 
                userId, user.getTotalStep(), user.getRemainingStep());
            
            // 如果是今天的数据，需要更新；如果是历史数据，只更新总步数
            if (recordDate.equals(LocalDate.now())) {
                // 使用之前保存的原始步数计算差值
                int stepDiff = todaySteps - previousTodaySteps;
                
                log.info("今日步数更新 - 用户: {}, 之前: {}, 现在: {}, 差值: {}", 
                    userId, previousTodaySteps, todaySteps, stepDiff);
                
                // 更新用户的剩余步数：累加差值（不是直接设置）
                Integer currentRemainingStep = user.getRemainingStep() != null ? user.getRemainingStep() : 0;
                int newRemainingStep = currentRemainingStep + stepDiff;
                user.setRemainingStep(newRemainingStep);
                
                log.info("剩余步数更新 - 用户: {}, 旧值: {}, 新值: {}, 差值: {}", 
                    userId, currentRemainingStep, newRemainingStep, stepDiff);
                
                // 更新总步数：累加差值
                Integer oldTotalStep = user.getTotalStep() != null ? user.getTotalStep() : 0;
                int newTotalStep = oldTotalStep + stepDiff;
                user.setTotalStep(newTotalStep);
                
                log.info("总步数更新 - 用户: {}, 旧值: {}, 新值: {}, 差值: {}", 
                    userId, oldTotalStep, newTotalStep, stepDiff);
            } else {
                // 历史数据，只更新总步数
                Integer oldTotalStep = user.getTotalStep() != null ? user.getTotalStep() : 0;
                int newTotalStep = oldTotalStep + todaySteps;
                user.setTotalStep(newTotalStep);
                
                log.info("历史步数更新 - 用户: {}, 日期: {}, 步数: {}, 旧总步数: {}, 新总步数: {}", 
                    userId, recordDate, todaySteps, oldTotalStep, newTotalStep);
            }
            
            // 更新最大日步数
            if (user.getMaxDailySteps() == null || todaySteps > user.getMaxDailySteps()) {
                user.setMaxDailySteps(todaySteps);
                log.info("更新最大日步数 - 用户: {}, 新最大值: {}", userId, todaySteps);
            }
            
            // 使用 UpdateWrapper 显式更新字段，确保数据库真正执行 UPDATE
            com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User> updateWrapper = 
                new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<>();
            updateWrapper.eq("id", userId)
                        .set("total_step", user.getTotalStep())
                        .set("remaining_step", user.getRemainingStep())
                        .set("max_daily_steps", user.getMaxDailySteps());
            
            log.info("准备更新数据库 - 用户ID: {}, 总步数: {}, 剩余步数: {}, 最大日步数: {}", 
                userId, user.getTotalStep(), user.getRemainingStep(), user.getMaxDailySteps());
            
            boolean updateSuccess = this.update(null, updateWrapper);
            
            log.info("数据库更新结果 - 是否成功: {}", updateSuccess);
            
            if (!updateSuccess) {
                log.error("数据库更新失败！");
                throw new RuntimeException("数据库更新失败");
            }
            
            // 验证更新是否成功
            User updatedUser = this.getById(userId);
            log.info("验证更新 - 用户ID: {}, 总步数: {}, 剩余步数: {}, 最大日步数: {}",
                updatedUser.getId(), updatedUser.getTotalStep(), updatedUser.getRemainingStep(), updatedUser.getMaxDailySteps());
            
            if (!updatedUser.getTotalStep().equals(user.getTotalStep())) {
                log.error("验证失败！期望总步数: {}, 实际: {}", user.getTotalStep(), updatedUser.getTotalStep());
                throw new RuntimeException("数据验证失败");
            }
            
            if (!updatedUser.getRemainingStep().equals(user.getRemainingStep())) {
                log.error("验证失败！期望剩余步数: {}, 实际: {}", user.getRemainingStep(), updatedUser.getRemainingStep());
                throw new RuntimeException("数据验证失败");
            }
            
            log.info("用户信息更新完成 - 用户: {}, 总步数: {}, 剩余步数: {}, 最大日步数: {}", 
                userId, user.getTotalStep(), user.getRemainingStep(), user.getMaxDailySteps());
        } else {
            log.error("未找到用户信息 - 用户ID: {}", userId);
        }
        
        // 4. 同步更新Redis排行榜
        updateRedisRanking(userId, todaySteps, recordDate);
        
        log.info("步数上传成功，用户: {}, 总步数: {}", userId, user != null ? user.getTotalStep() : 0);
    }
    
    /**
     * 更新Redis排行榜
     */
    private void updateRedisRanking(Long userId, int steps, LocalDate date) {
        try {
            // 日榜：直接使用add覆盖（因为每次上传的是当天的总步数）
            String dailyKey = DAILY_RANK_KEY_PREFIX + date.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            redisTemplate.opsForZSet().add(dailyKey, userId, steps);
            log.info("Redis日榜更新成功，用户: {}, key: {}, 步数: {}", userId, dailyKey, steps);
            
            // 周榜：需要计算本周累计步数
            String weekKey = WEEKLY_RANK_KEY_PREFIX + date.getYear() + 
                String.format("%02d", date.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR));
            // 查询本周的总步数
            LocalDate weekStart = date.minusDays(date.getDayOfWeek().getValue() - 1); // 本周一
            List<StepRecord> weekRecords = stepRecordMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                    .eq(StepRecord::getUserId, userId)
                    .ge(StepRecord::getRecordDate, weekStart)
                    .le(StepRecord::getRecordDate, date)
            );
            int weekSteps = weekRecords.stream().mapToInt(StepRecord::getStepCount).sum();
            redisTemplate.opsForZSet().add(weekKey, userId, weekSteps);
            log.info("Redis周榜更新成功，用户: {}, key: {}, 本周总步数: {}", userId, weekKey, weekSteps);
            
            // 月榜：需要计算本月累计步数
            String monthKey = MONTHLY_RANK_KEY_PREFIX + date.format(DateTimeFormatter.ofPattern("yyyyMM"));
            // 查询本月的总步数
            LocalDate monthStart = date.withDayOfMonth(1); // 本月第一天
            List<StepRecord> monthRecords = stepRecordMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                    .eq(StepRecord::getUserId, userId)
                    .ge(StepRecord::getRecordDate, monthStart)
                    .le(StepRecord::getRecordDate, date)
            );
            int monthSteps = monthRecords.stream().mapToInt(StepRecord::getStepCount).sum();
            redisTemplate.opsForZSet().add(monthKey, userId, monthSteps);
            log.info("Redis月榜更新成功，用户: {}, key: {}, 本月总步数: {}", userId, monthKey, monthSteps);
            
        } catch (Exception e) {
            log.error("更新Redis排行榜失败，用户: {}", userId, e);
            // 不抛出异常，避免影响主流程
        }
    }

    @Override
    public StepStatisticsVo getStepStatistics() {
        Long userId = UserContext.getUserId();
        log.info("获取用户 {} 的步数统计", userId);
        
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1); // 本周一
        LocalDate monthStart = today.withDayOfMonth(1); // 本月第一天
        
        // 查询今日步数
        StepRecord todayRecord = stepRecordMapper.selectOne(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .eq(StepRecord::getRecordDate, today)
        );
        int todaySteps = todayRecord != null ? todayRecord.getStepCount() : 0;
        
        // 查询本周步数
        List<StepRecord> weekRecords = stepRecordMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .ge(StepRecord::getRecordDate, weekStart)
                .le(StepRecord::getRecordDate, today)
        );
        int weekSteps = weekRecords.stream().mapToInt(StepRecord::getStepCount).sum();
        
        // 查询本月步数
        List<StepRecord> monthRecords = stepRecordMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .ge(StepRecord::getRecordDate, monthStart)
                .le(StepRecord::getRecordDate, today)
        );
        int monthSteps = monthRecords.stream().mapToInt(StepRecord::getStepCount).sum();
        
        // 获取用户信息
        User user = this.getById(userId);
        int totalSteps = user != null && user.getTotalStep() != null ? user.getTotalStep() : 0;
        int maxDailySteps = user != null && user.getMaxDailySteps() != null ? user.getMaxDailySteps() : 0;
        
        // 计算平均每日步数（本月）
        long daysInMonth = monthRecords.size();
        double avgDailySteps = daysInMonth > 0 ? (double) monthSteps / daysInMonth : 0;
        
        // 查询最小日步数（本月）
        int minDailySteps = monthRecords.stream()
            .mapToInt(StepRecord::getStepCount)
            .min()
            .orElse(0);
        
        StepStatisticsVo statistics = new StepStatisticsVo();
        statistics.setTodaySteps(todaySteps);
        statistics.setWeekSteps(weekSteps);
        statistics.setMonthSteps(monthSteps);
        statistics.setTotalSteps(totalSteps);
        statistics.setAvgDailySteps((double) Math.round(avgDailySteps));
        statistics.setMaxDailySteps(maxDailySteps);
        statistics.setMinDailySteps(minDailySteps);
        statistics.setLastUpdate(LocalDateTime.now().toString());
        
        return statistics;
    }

    @Override
    public List<StepTrendVo> getStepTrend(int days) {
        Long userId = UserContext.getUserId();
        log.info("获取用户 {} 最近 {} 天的步数趋势", userId, days);
        
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1);
        
        // 查询指定日期范围内的步数记录
        List<StepRecord> records = stepRecordMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .ge(StepRecord::getRecordDate, startDate)
                .le(StepRecord::getRecordDate, endDate)
                .orderByAsc(StepRecord::getRecordDate)
        );
        
        // 构建完整的日期序列（包括没有步数记录的日期）
        List<StepTrendVo> trendList = new ArrayList<>();
        for (int i = 0; i < days; i++) {
            LocalDate date = startDate.plusDays(i);
            String dateStr = date.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            
            // 查找该日期的步数记录
            int steps = records.stream()
                .filter(r -> r.getRecordDate().equals(date))
                .mapToInt(StepRecord::getStepCount)
                .findFirst()
                .orElse(0);
            
            StepTrendVo trendVo = new StepTrendVo(dateStr, steps);
            trendList.add(trendVo);
        }
        
        log.info("返回 {} 天的步数趋势数据", trendList.size());
        return trendList;
    }

    @Override
    public List<StepRecordVo> getStepRecords(int pageNum, int pageSize) {
        Long userId = UserContext.getUserId();
        log.info("获取用户 {} 的步数记录列表，页码: {}, 每页: {}", userId, pageNum, pageSize);
        
        // 使用MyBatis-Plus分页查询
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<StepRecord> page = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord> wrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .orderByDesc(StepRecord::getRecordDate);
        
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<StepRecord> resultPage = 
            stepRecordMapper.selectPage(page, wrapper);
        
        // 转换为VO
        List<StepRecordVo> recordVoList = resultPage.getRecords().stream()
            .map(record -> {
                StepRecordVo vo = new StepRecordVo();
                vo.setId(record.getId());
                vo.setRecordDate(record.getRecordDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                vo.setStepCount(record.getStepCount());
                vo.setLastUploadTime(record.getLastUploadTime() != null ? 
                    record.getLastUploadTime().toString() : "");
                return vo;
            })
            .collect(java.util.stream.Collectors.toList());
        
        log.info("返回 {} 条步数记录", recordVoList.size());
        return recordVoList;
    }

    @Override
    public List<ExchangeRecordVo> getExchangeRecords(int pageNum, int pageSize) {
        Long userId = UserContext.getUserId();
        log.info("获取用户 {} 的兑换记录列表，页码: {}, 每页: {}", userId, pageNum, pageSize);
        
        List<ExchangeRecordVo> allRecords = new ArrayList<>();
        
        // 1. 查询步数记录
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<StepRecord> stepPage = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord> stepWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<StepRecord>()
                .eq(StepRecord::getUserId, userId)
                .orderByDesc(StepRecord::getRecordDate);
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<StepRecord> stepResultPage = 
            stepRecordMapper.selectPage(stepPage, stepWrapper);
        
        // 转换为ExchangeRecordVo
        for (StepRecord record : stepResultPage.getRecords()) {
            ExchangeRecordVo vo = new ExchangeRecordVo();
            vo.setId(record.getId());
            vo.setType("step_record");
            vo.setSteps(record.getStepCount());
            vo.setPoints(0);
            vo.setExchangeTime(record.getLastUploadTime() != null ? 
                LocalDateTime.parse(record.getLastUploadTime().toString()) : LocalDateTime.now());
            vo.setDescription("步数记录");
            allRecords.add(vo);
        }
        
        // 2. 查询积分兑换记录
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<PointsLog> pointsPage = 
            new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(pageNum, pageSize);
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PointsLog> pointsWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<PointsLog>()
                .eq(PointsLog::getUserId, userId)
                .orderByDesc(PointsLog::getCreateTime);
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<PointsLog> pointsResultPage = 
            pointsLogMapper.selectPage(pointsPage, pointsWrapper);
        
        // 转换为ExchangeRecordVo
        for (PointsLog log : pointsResultPage.getRecords()) {
            ExchangeRecordVo vo = new ExchangeRecordVo();
            vo.setId(log.getId());
            vo.setType("points_exchange");
            vo.setSteps(log.getBeforeStep() - log.getAfterStep()); // 消耗的步数
            vo.setPoints(log.getPointsAmount());
            vo.setExchangeTime(log.getCreateTime());
            vo.setDescription("积分兑换");
            allRecords.add(vo);
        }
        
        // 3. 按时间排序（最新的在前）
        allRecords.sort((a, b) -> b.getExchangeTime().compareTo(a.getExchangeTime()));
        
        // 4. 分页处理（如果总数超过pageSize，只返回前pageSize条）
        if (allRecords.size() > pageSize) {
            allRecords = allRecords.subList(0, pageSize);
        }
        
        log.info("返回 {} 条兑换记录", allRecords.size());
        return allRecords;
    }
}
