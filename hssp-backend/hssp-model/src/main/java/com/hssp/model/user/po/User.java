package com.hssp.model.user.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("user")
public class User {
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
    /**
     * 用户名
     */
    private String username;
    /**
     * 密码
     */
    private String password;
    /**
     * 邮箱
     */
    private String email;
    /**
     * 昵称
     */
    private String nickname;
    /**
     * 性别
     */
    private Short sex;
    /**
     * 头像
     */
    private String avatar;
    /**
     * 总积分
     */
    private Integer totalPoints;
    /**
     * 总步数
     */
    private Integer totalStep;
    /**
     * 剩余步数
     */
    private Integer remainingStep;
    /**
     * 最大每日步数
     */
    private Integer maxDailySteps;
    /**
     * 是否删除
     */
    private Short isDeleted;
    /**
     * 创建时间
     */
    private LocalDateTime createTime;
    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}
