package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVo {
    private Long id;  // 用户ID
    private String username;  // 用户名
    private String email;  // 邮箱
    private String nickname;  // 昵称
    private Short sex;  // 性别: 1男, 2女
    private String avatar;  // 头像
    /**
     * 总步数 (前端期望字段名: totalSteps)
     */
    private Integer totalStep;
    /**
     * 总积分 (前端需要)
     */
    private Integer totalPoints;
    /**
     * 剩余步数 (前端需要)
     */
    private Integer remainingStep;
    /**
     * 最大每日步数
     */
    private Integer maxDailySteps;
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}
