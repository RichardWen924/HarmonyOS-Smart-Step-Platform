package com.hssp.model.user.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 步数记录VO - 用于数据分析页面
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StepRecordVo {
    private Long id;
    private String recordDate;     // 记录日期 (yyyy-MM-dd)
    private Integer stepCount;     // 步数
    private String lastUploadTime; // 最后上传时间
}
