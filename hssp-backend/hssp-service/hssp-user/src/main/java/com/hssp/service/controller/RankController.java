package com.hssp.service.controller;



import com.hssp.common.context.UserContext;
import com.hssp.common.result.Result;
import com.hssp.model.common.result.PageResult;
import com.hssp.model.vo.RankVO;
import com.hssp.service.service.RankService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;


@RestController
@RequestMapping("/user")
public class RankController {

    @Resource
    private RankService rankService;

    /**
     * 查看步数排行榜 (日、周、月)
     *
     * @param periodType 周期类型：day（日排行）、week（周排行）、month（月排行）
     * @param pageNum 请求拉取的页码 (默认第一页)
     * @param pageSize 每页的个数 (默认10)
     * @return Result
     */
    @GetMapping("/rankings")
    public Result getRankList(
            @RequestParam(defaultValue = "day") String periodType,
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "100") int pageSize) {

        // 从 UserContext 获取当前登录用户ID
        Long currentUserId = UserContext.getUserId();
        
        PageResult<RankVO> pageData = rankService.getRankingData(periodType, pageNum, pageSize, currentUserId);

        return Result.success(pageData);
    }
}
