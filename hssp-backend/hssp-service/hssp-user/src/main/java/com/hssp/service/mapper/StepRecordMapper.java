package com.hssp.service.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hssp.model.user.po.StepRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 步数记录Mapper
 */
@Mapper
public interface StepRecordMapper extends BaseMapper<StepRecord> {
}
