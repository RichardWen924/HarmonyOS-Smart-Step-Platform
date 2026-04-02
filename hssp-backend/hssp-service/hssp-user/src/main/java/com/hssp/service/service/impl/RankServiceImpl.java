package com.hssp.service.service.impl;

import com.hssp.model.common.result.PageResult;
import com.hssp.model.user.po.User;
import com.hssp.model.vo.RankVO;
import com.hssp.service.service.IUserService;
import com.hssp.service.service.RankService;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.IsoFields;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class RankServiceImpl implements RankService {

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    @Resource
    private IUserService userService;

    private static final String DAILY_RANK_KEY_PREFIX = "hssp:rank:daily:";
    private static final String WEEKLY_RANK_KEY_PREFIX = "hssp:rank:week:";
    private static final String MONTHLY_RANK_KEY_PREFIX = "hssp:rank:month:";

    @Override
    public PageResult<RankVO> getRankingData(String periodType, int pageNum, int pageSize, Long currentUserId) {
        String redisKey = getRedisKeyByPeriod(periodType);

        // 1. 获取 ZSet 总数
        Long totalElements = redisTemplate.opsForZSet().zCard(redisKey);
        long total = totalElements == null ? 0L : totalElements;

        // 计算总页数
        int pages = (int) Math.ceil((double) total / pageSize);

        // 2. 计算分页边界
        long start = (long) (pageNum - 1) * pageSize;
        long stop = start + pageSize - 1;

        // 3. 查榜缓存 (逆序)
        Set<ZSetOperations.TypedTuple<Object>> tupleSet = 
            redisTemplate.opsForZSet().reverseRangeWithScores(redisKey, start, stop);

        List<RankVO> rankList = new ArrayList<>();
        
        if (tupleSet != null && !tupleSet.isEmpty()) {
            // 提取所有的用户ID
            List<Long> userIds = tupleSet.stream()
                    .map(tuple -> Long.valueOf(tuple.getValue().toString()))
                    .collect(Collectors.toList());

            // 4. 调用本系统的 IUserService 批量获取用户信息
            List<User> users = userService.listByIds(userIds);
            Map<Long, User> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, u -> u));

            long currentRank = start + 1;
            for (ZSetOperations.TypedTuple<Object> tuple : tupleSet) {
                Long uId = Long.valueOf(tuple.getValue().toString());
                Double score = tuple.getScore();
                User user = userMap.get(uId);

                RankVO rankVO = new RankVO();
                rankVO.setRank(currentRank++);
                rankVO.setUserId(uId);
                rankVO.setTotalSteps(score);
                if (user != null) {
                    rankVO.setNickname(user.getNickname());
                    rankVO.setAvatar(user.getAvatar());
                } else {
                    rankVO.setNickname("Unknown");
                    rankVO.setAvatar("");
                }
                rankList.add(rankVO);
            }
        }

        // 5. 组装并返回 PageResult
        return new PageResult<>(total, rankList, pages, pageNum);
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
