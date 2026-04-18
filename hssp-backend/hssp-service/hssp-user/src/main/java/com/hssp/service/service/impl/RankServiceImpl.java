package com.hssp.service.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hssp.model.common.result.PageResult;
import com.hssp.model.user.po.StepRecord;
import com.hssp.model.user.po.User;
import com.hssp.model.vo.RankVO;
import com.hssp.service.mapper.StepRecordMapper;
import com.hssp.service.service.IUserService;
import com.hssp.service.service.RankService;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.IsoFields;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class RankServiceImpl implements RankService {

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    @Resource
    private IUserService userService;
    
    @Resource
    private StepRecordMapper stepRecordMapper;

    private static final String DAILY_RANK_KEY_PREFIX = "hssp:rank:daily:";
    private static final String WEEKLY_RANK_KEY_PREFIX = "hssp:rank:week:";
    private static final String MONTHLY_RANK_KEY_PREFIX = "hssp:rank:month:";

    @Override
    public PageResult<RankVO> getRankingData(String periodType, int pageNum, int pageSize, Long currentUserId) {
        // 从数据库查询所有用户的步数记录
        List<UserStepData> userStepDataList = queryUserStepsFromDatabase(periodType);
        
        // 按步数降序排序
        userStepDataList.sort((a, b) -> Integer.compare(b.steps, a.steps));
        
        // 计算总数和分页
        long total = userStepDataList.size();
        int pages = (int) Math.ceil((double) total / pageSize);
        
        // 分页截取
        int fromIndex = (pageNum - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, userStepDataList.size());
        
        if (fromIndex >= userStepDataList.size()) {
            return new PageResult<>(total, new ArrayList<>(), pages, pageNum);
        }
        
        List<UserStepData> pageData = userStepDataList.subList(fromIndex, toIndex);
        
        // 获取所有用户ID
        List<Long> userIds = pageData.stream()
            .map(data -> data.userId)
            .collect(Collectors.toList());
        
        // 批量查询用户信息
        List<User> users = userService.listByIds(userIds);
        Map<Long, User> userMap = users.stream()
            .collect(Collectors.toMap(User::getId, u -> u));
        
        // 构建排行榜列表
        List<RankVO> rankList = new ArrayList<>();
        long currentRank = fromIndex + 1;
        
        for (UserStepData data : pageData) {
            User user = userMap.get(data.userId);
            
            RankVO rankVO = new RankVO();
            rankVO.setRank(currentRank++);
            rankVO.setUserId(data.userId);
            rankVO.setTotalSteps(Double.valueOf(data.steps));
            
            if (user != null) {
                // 优先使用昵称，如果没有则使用用户名或邮箱前缀
                String nickname = user.getNickname();
                if (nickname == null || nickname.trim().isEmpty()) {
                    nickname = user.getUsername();
                    if (nickname == null || nickname.trim().isEmpty()) {
                        // 如果用户名为空，使用邮箱@前面的部分
                        String email = user.getEmail();
                        if (email != null && email.contains("@")) {
                            nickname = email.substring(0, email.indexOf("@"));
                        } else {
                            nickname = "用户" + data.userId;
                        }
                    }
                }
                rankVO.setNickname(nickname);
                
                // 设置头像
                String avatar = user.getAvatar();
                if (avatar == null || avatar.trim().isEmpty()) {
                    avatar = ""; // 前端会显示默认头像
                }
                rankVO.setAvatar(avatar);
            } else {
                rankVO.setNickname("未知用户");
                rankVO.setAvatar("");
            }
            
            rankList.add(rankVO);
        }
        
        // 返回分页结果
        return new PageResult<>(total, rankList, pages, pageNum);
    }
    
    @Override
    public RankVO getUserRanking(String periodType, Long userId) {
        // 从数据库查询所有用户的步数记录
        List<UserStepData> userStepDataList = queryUserStepsFromDatabase(periodType);
        
        // 按步数降序排序
        userStepDataList.sort((a, b) -> Integer.compare(b.steps, a.steps));
        
        // 查找当前用户的位置
        for (int i = 0; i < userStepDataList.size(); i++) {
            UserStepData data = userStepDataList.get(i);
            if (data.userId.equals(userId)) {
                // 找到用户，构建排名信息
                User user = userService.getById(userId);
                
                RankVO rankVO = new RankVO();
                rankVO.setRank((long) (i + 1)); // 排名从1开始
                rankVO.setUserId(userId);
                rankVO.setTotalSteps(Double.valueOf(data.steps));
                
                if (user != null) {
                    String nickname = user.getNickname();
                    if (nickname == null || nickname.trim().isEmpty()) {
                        nickname = user.getUsername();
                        if (nickname == null || nickname.trim().isEmpty()) {
                            String email = user.getEmail();
                            if (email != null && email.contains("@")) {
                                nickname = email.substring(0, email.indexOf("@"));
                            } else {
                                nickname = "用户" + userId;
                            }
                        }
                    }
                    rankVO.setNickname(nickname);
                    
                    String avatar = user.getAvatar();
                    if (avatar == null || avatar.trim().isEmpty()) {
                        avatar = "";
                    }
                    rankVO.setAvatar(avatar);
                } else {
                    rankVO.setNickname("未知用户");
                    rankVO.setAvatar("");
                }
                
                return rankVO;
            }
        }
        
        // 未上榜
        return null;
    }
    
    /**
     * 从数据库查询用户步数数据
     */
    private List<UserStepData> queryUserStepsFromDatabase(String periodType) {
        LocalDate now = LocalDate.now();
        LocalDate startDate;
        LocalDate endDate = now;
        
        // 根据周期类型确定日期范围
        if ("week".equalsIgnoreCase(periodType)) {
            // 本周：从本周一到今天
            startDate = now.minusDays(now.getDayOfWeek().getValue() - 1);
        } else if ("month".equalsIgnoreCase(periodType)) {
            // 本月：从本月第一天到今天
            startDate = now.withDayOfMonth(1);
        } else {
            // 日榜：今天
            startDate = now;
        }
        
        // 查询指定日期范围内的所有步数记录
        LambdaQueryWrapper<StepRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(StepRecord::getRecordDate, startDate)
               .le(StepRecord::getRecordDate, endDate);
        
        List<StepRecord> records = stepRecordMapper.selectList(wrapper);
        
        // 按用户ID分组，计算每个用户的总步数
        Map<Long, Integer> userStepsMap = records.stream()
            .collect(Collectors.groupingBy(
                StepRecord::getUserId,
                Collectors.summingInt(StepRecord::getStepCount)
            ));
        
        // 转换为UserStepData列表
        return userStepsMap.entrySet().stream()
            .map(entry -> new UserStepData(entry.getKey(), entry.getValue()))
            .collect(Collectors.toList());
    }
    
    /**
     * 用户步数数据内部类
     */
    private static class UserStepData {
        Long userId;
        Integer steps;
        
        public UserStepData(Long userId, Integer steps) {
            this.userId = userId;
            this.steps = steps;
        }
    }

    private String getRedisKeyByPeriod(String periodType) {
        LocalDate now = LocalDate.now();
        if ("week".equalsIgnoreCase(periodType)) {
            // week: hssp:rank:week:{yyyyww}
            int year = now.get(IsoFields.WEEK_BASED_YEAR);
            int week = now.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR);
            return WEEKLY_RANK_KEY_PREFIX + year + String.format("%02d", week);
        } else if ("month".equalsIgnoreCase(periodType)) {
            // month: hssp:rank:month:{yyyyMM}
            String monthStr = now.format(DateTimeFormatter.ofPattern("yyyyMM"));
            return MONTHLY_RANK_KEY_PREFIX + monthStr;
        } else {
            // day (默认): hssp:rank:daily:{yyyyMMdd}
            String todayStr = now.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            return DAILY_RANK_KEY_PREFIX + todayStr;
        }
    }
}
