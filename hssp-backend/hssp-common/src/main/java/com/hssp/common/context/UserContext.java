package com.hssp.common.context;

public class UserContext {
    private static final ThreadLocal<Long> threadLocalUserContext = new ThreadLocal<Long>();
    public static Long getUserId() {
        return threadLocalUserContext.get();
    }
    public static void setUserId(Long userId) {
        threadLocalUserContext.set(userId);
    }
    public static void removeUserId() {
        threadLocalUserContext.remove();
    }
}
