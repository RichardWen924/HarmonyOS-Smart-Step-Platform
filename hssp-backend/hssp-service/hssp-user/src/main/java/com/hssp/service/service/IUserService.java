package com.hssp.service.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.user.dto.ChangeInfoDto;
import com.hssp.model.user.dto.ChangePasswordDto;
import com.hssp.model.user.dto.LoginDto;
import com.hssp.model.user.dto.RegisterDto;
import com.hssp.model.user.dto.StepUploadDto;
import com.hssp.model.user.po.User;
import com.hssp.model.user.vo.ExchangeRecordVo;
import com.hssp.model.user.vo.StepRecordVo;
import com.hssp.model.user.vo.StepStatisticsVo;
import com.hssp.model.user.vo.StepTrendVo;

import java.util.List;

public interface IUserService extends IService<User> {

    void register(RegisterDto registerDto);
    String login(LoginDto loginDto);
    void update(ChangeInfoDto changeInfoDto);
    void updatePassword(ChangePasswordDto changePasswordDto);
    Integer getPoints();
    
    /**
     * 上传步数
     * @param stepUploadDto 步数上传DTO
     */
    void uploadSteps(StepUploadDto stepUploadDto);
    
    /**
     * 获取步数统计数据
     * @return 步数统计VO
     */
    StepStatisticsVo getStepStatistics();
    
    /**
     * 获取步数趋势数据（最近N天）
     * @param days 天数，默认7天
     * @return 步数趋势列表
     */
    List<StepTrendVo> getStepTrend(int days);
    
    /**
     * 获取用户步数记录列表（用于数据分析页面）
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 步数记录列表
     */
    List<StepRecordVo> getStepRecords(int pageNum, int pageSize);
    
    /**
     * 获取用户兑换记录列表（包含步数记录和积分兑换记录）
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 兑换记录列表
     */
    List<ExchangeRecordVo> getExchangeRecords(int pageNum, int pageSize);
}
