package com.hssp.service.mall.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.mall.service.MallGoodsService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/goods/admin")
public class AdminGoodsController {

    @Autowired
    private MallGoodsService mallGoodsService;

    @PostMapping
    public Result add(@RequestBody MallGoods goods) {
        mallGoodsService.save(goods);
        return Result.success("添加商品成功");
    }

    @PutMapping
    public Result update(@RequestBody MallGoods goods) {
        if (goods.getId() == null) {
            return Result.error("商品ID不能为空");
        }
        mallGoodsService.updateById(goods);
        return Result.success("修改商品成功");
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Long id) {
        mallGoodsService.removeById(id);
        return Result.success("删除商品成功");
    }

    @PutMapping("/status/{id}")
    public Result changeStatus(@PathVariable Long id, @RequestParam Integer status) {
        if (status != 0 && status != 1) {
            return Result.error("状态参数不合法 (0:上架, 1:下架)");
        }
        try {
            mallGoodsService.changeStatus(id, status);
            return Result.success(status == 0 ? "上架成功" : "下架成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result list() {
        return Result.success(mallGoodsService.listAll());
    }

    @GetMapping("/page")
    public Result page(@RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size) {
        return Result.success(mallGoodsService.pageAll(page, size));
    }

    @GetMapping("/{id}")
    public Result getById(@PathVariable Long id) {
        return Result.success(mallGoodsService.getGoodsById(id));
    }
}
