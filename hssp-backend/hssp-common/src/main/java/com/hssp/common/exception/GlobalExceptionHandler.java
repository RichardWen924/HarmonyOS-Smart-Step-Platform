package com.hssp.common.exception;

import com.hssp.common.result.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public Result businessException(BusinessException e) {
        log.error("业务异常：{}", e.getMessage());
        
        // 对于登录、注册等用户友好的错误信息，直接返回原始消息
        String message = e.getMessage();
        if (message != null && (
            message.contains("密码") || 
            message.contains("用户名") || 
            message.contains("邮箱") || 
            message.contains("验证码") ||
            message.contains("登录") ||
            message.contains("注册")
        )) {
            return Result.error(message);
        }
        
        // 其他业务异常添加前缀
        return Result.error("业务异常：" + e.getMessage());
    }

    /**
     * 处理运行时异常
     */
    @ExceptionHandler(RuntimeException.class)
    public Result handleRuntimeException(RuntimeException e) {
        log.error("运行时异常: {}", e.getMessage(), e);
        return Result.error("系统运行时异常");
    }

    /**
     * 处理空指针异常
     */
    @ExceptionHandler(NullPointerException.class)
    public Result handleNullPointerException(NullPointerException e) {
        log.error("空指针异常: {}", e.getMessage(), e);
        return Result.error("系统空指针异常");
    }

    /**
     * 处理非法参数异常
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public Result handleIllegalArgumentException(IllegalArgumentException e) {
        log.error("非法参数异常: {}", e.getMessage(), e);
        return Result.error("非法参数异常：" + e.getMessage());
    }

    /**
     * 处理所有异常
     */
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e) {
        log.error("系统异常: {}", e.getMessage(), e);
        return Result.error("系统内部异常");
    }
}
