package com.hssp.common.admin;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;

@Getter
public enum PointRules_Status {
    ENABLE(1, "启用"),
    DISABLE(0, "禁用");

    @EnumValue
    @JsonValue
    private final Integer code;
    private final String desc;

    PointRules_Status(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}