package com.hssp.service.service;

import com.hssp.model.common.result.PageResult;
import com.hssp.model.vo.RankVO;

public interface RankService {
    /**
     * 获取步数排行榜列表
     * @param periodType 周期类型：day（日排行）、week（周排行）、month（月排行）
     * @param pageNum 页码
     * @param pageSize 每页大小
     * @param currentUserId 当前操作的用户ID
     * @return 包含 total 和 list 的分页结果
     */
    PageResult<RankVO> getRankingData(String periodType, int pageNum, int pageSize, Long currentUserId);
}
