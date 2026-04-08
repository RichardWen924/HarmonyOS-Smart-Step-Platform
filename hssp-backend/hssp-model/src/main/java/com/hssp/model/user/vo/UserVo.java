package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVo {
    private String username;
    private String nickname;
    private Short sex;
    private String avatar;
    /**
     * 总步数
     */
    private Integer totalStep;
    /**
     * 最大每日步数
     */
    private Integer maxDailySteps;
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}
