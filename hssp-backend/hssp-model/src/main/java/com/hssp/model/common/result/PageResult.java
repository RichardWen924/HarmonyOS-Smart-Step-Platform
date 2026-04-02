package com.hssp.model.common.result;

import java.io.Serializable;
import java.util.List;

/**
 * 分页结果封装类，兼容 PageHelper 参数风格
 */
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 总记录数
     */
    private long total;

    /**
     * 当前页数据列表
     */
    private List<T> list;

    /**
     * 总页数
     */
    private int pages;

    /**
     * 当前页码
     */
    private int pageNum;

    public PageResult() {
    }

    public PageResult(long total, List<T> list, int pages, int pageNum) {
        this.total = total;
        this.list = list;
        this.pages = pages;
        this.pageNum = pageNum;
    }

    public long getTotal() {
        return total;
    }

    public void setTotal(long total) {
        this.total = total;
    }

    public List<T> getList() {
        return list;
    }

    public void setList(List<T> list) {
        this.list = list;
    }

    public int getPages() {
        return pages;
    }

    public void setPages(int pages) {
        this.pages = pages;
    }

    public int getPageNum() {
        return pageNum;
    }

    public void setPageNum(int pageNum) {
        this.pageNum = pageNum;
    }
}
