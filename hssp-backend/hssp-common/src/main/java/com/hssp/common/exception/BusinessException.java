package com.hssp.common.exception;

import lombok.*;

/**
 * 业务异常
 */
@Getter
@EqualsAndHashCode(callSuper = false)
public class BusinessException extends BaseException {
    public BusinessException(String message, Integer code) {
        super(message, code);
    }

    public BusinessException(String message) {
        super(message);
    }
}