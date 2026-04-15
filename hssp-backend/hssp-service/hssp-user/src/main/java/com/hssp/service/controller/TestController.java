package com.hssp.service.controller;

import com.hssp.common.result.Result;
import com.hssp.service.task.StepScheduleTask;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 测试控制器（仅用于开发和测试环境）
 * 提供手动触发定时任务的接口
 */
@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestController {

    private final StepScheduleTask stepScheduleTask;

    /**
     * 手动触发步数清零任务
     * 注意：此接口仅用于测试，生产环境应该禁用
     */
    @PostMapping("/reset-steps")
    public Result testResetSteps() {
        try {
            stepScheduleTask.resetDailySteps();
            return Result.success("步数清零任务执行成功");
        } catch (Exception e) {
            return Result.error("步数清零任务执行失败: " + e.getMessage());
        }
    }
}
