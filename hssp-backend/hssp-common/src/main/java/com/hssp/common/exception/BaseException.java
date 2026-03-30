package com.hssp.common.exception;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
public class BaseException extends RuntimeException {
    private Integer code;
    public BaseException(String message, Integer code) {
        super(message);
        this.code = code;
    }
    public BaseException(String message) {
        super(message);
        this.code = 500;
    }
}
