package com.hssp.service.controller;

import com.hssp.common.result.Result;
import com.hssp.model.mall.po.MallGoods;
import com.hssp.service.service.AdminMallGoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/goods")
public class AdminMallGoodsController {

    @Autowired
    private AdminMallGoodsService adminMallGoodsService;

    @PostMapping
    public Result add(@RequestBody MallGoods goods) {
        adminMallGoodsService.save(goods);
        return Result.success("添加商品成功");
    }

    @PutMapping
    public Result update(@RequestBody MallGoods goods) {
        if (goods.getId() == null) {
            return Result.error("商品ID不能为空");
        }
        adminMallGoodsService.updateById(goods);
        return Result.success("修改商品成功");
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Long id) {
        adminMallGoodsService.removeById(id);
        return Result.success("删除商品成功");
    }

    @PutMapping("/status/{id}")
    public Result changeStatus(@PathVariable Long id, @RequestParam Integer status) {
        if (status != 0 && status != 1) {
            return Result.error("状态参数不合法 (0:上架, 1:下架)");
        }
        try {
            adminMallGoodsService.changeStatus(id, status);
            return Result.success(status == 0 ? "上架成功" : "下架成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result list() {
        return Result.success(adminMallGoodsService.listAll());
    }

    @GetMapping("/page")
    public Result page(@RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size) {
        return Result.success(adminMallGoodsService.pageAll(page, size));
    }

    @GetMapping("/{id}")
    public Result getById(@PathVariable Long id) {
        return Result.success(adminMallGoodsService.getGoodsById(id));
    }
}
