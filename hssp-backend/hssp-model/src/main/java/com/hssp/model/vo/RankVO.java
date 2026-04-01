package com.hssp.model.vo;

import java.io.Serializable;

/**
 * 单条排行榜展示视图
 */
public class RankVO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 名次 (-1 表示未上榜)
     */
    private Long rank;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 用户昵称
     */
    private String nickname;

    /**
     * 用户头像
     */
    private String avatar;

    /**
     * 周期内总步数
     */
    private Double totalSteps;

    public RankVO() {
    }

    public RankVO(Long rank, Long userId, String nickname, String avatar, Double totalSteps) {
        this.rank = rank;
        this.userId = userId;
        this.nickname = nickname;
        this.avatar = avatar;
        this.totalSteps = totalSteps;
    }

    public Long getRank() {
        return rank;
    }

    public void setRank(Long rank) {
        this.rank = rank;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public Double getTotalSteps() {
        return totalSteps;
    }

    public void setTotalSteps(Double totalSteps) {
        this.totalSteps = totalSteps;
    }
}
