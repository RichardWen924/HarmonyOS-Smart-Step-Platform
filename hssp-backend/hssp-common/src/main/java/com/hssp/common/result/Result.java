package com.hssp.common.result;

import lombok.Data;

@Data
public class Result {

    private Integer code;
    private String msg;
    private Object data;

    public static Result success() {
        Result result = new Result();
        result.code = 1;
        result.msg = "success";
        return result;
    }

    public static Result success(Object object) {
        Result result =  new Result();
        result.data = object;
        result.code = 1;
        result.msg = "success";
        return result;
    }


    public static Result success(String msg,Object data){
        Result result =  new Result();
        result.msg = msg;
        result.code = 1;
        result.data = data;
        return result;
    }

    public static Result error(String msg) {
        Result result = new Result();
        result.msg = msg;
        result.code = 0;
        return result;
    }
}
