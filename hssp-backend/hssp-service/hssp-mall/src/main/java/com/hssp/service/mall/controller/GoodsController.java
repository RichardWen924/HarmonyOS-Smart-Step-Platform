package com.hssp.service.mall.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.mall.service.MallGoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/goods")
public class GoodsController {

    @Autowired
    private MallGoodsService mallGoodsService;

    @GetMapping("/list")
    public Result list() {
        List<MallGoods> goodsList = mallGoodsService.list();
        return Result.success(goodsList);
    }

    @GetMapping("/refresh")
    public Result refresh() {
        mallGoodsService.refreshGoodsCache();
        return Result.success("刷新缓存成功", mallGoodsService.list());
    }

    @GetMapping("/page")
    public Result page(@RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size) {
        return Result.success(mallGoodsService.page(page, size));
    }

    @GetMapping("/{id}")
    public Result getById(@PathVariable Long id) {
        return Result.success(mallGoodsService.getGoodsById(id));
    }
}
