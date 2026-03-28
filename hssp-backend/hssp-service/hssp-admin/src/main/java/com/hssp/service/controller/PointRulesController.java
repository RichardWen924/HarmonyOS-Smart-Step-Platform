package com.hssp.service.controller;

import cn.hutool.core.bean.BeanUtil;
import com.hssp.common.admin.PointRules_Status;
import com.hssp.model.admin.dto.IdsDto;
import com.hssp.model.admin.dto.PointRulesDto;

import com.hssp.model.admin.po.PointRules;
import com.hssp.model.admin.po.Result;
import com.hssp.service.service.PointRulesService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/points")
public class PointRulesController {

    @Autowired
    private PointRulesService pointRulesService;

    /**
     * 新增积分规则
     * @param pointRulesDto
     * @return
     */
    @PostMapping
    public Result insertPointRules(@RequestBody PointRulesDto pointRulesDto) {
        PointRules pointRules = BeanUtil.copyProperties(pointRulesDto, PointRules.class);
        pointRules.setIsActive(PointRules_Status.DISABLE);
        pointRulesService.save(pointRules);
        return Result.success();
    }

    /**
     * 查询积分规则
     * @return
     */
    @GetMapping
    public Result queryAll() {
        List<PointRules> pointRules = pointRulesService.list();
        return Result.success(pointRules);
    }

    /**
     * 根据id查询积分规则
     * @param id
     * @return
     */
    @GetMapping("/{id}")
    public Result queryById(@PathVariable Long id) {
        return Result.success(pointRulesService.getById(id));
    }

    /**
     * 修改积分规则
     * @param pointRulesDto
     * @return
     */
    @PutMapping
    public Result update(@RequestBody PointRulesDto pointRulesDto) {
        PointRules pointRules = BeanUtil.copyProperties(pointRulesDto, PointRules.class);
        pointRulesService.updateById(pointRules);
        return Result.success();
    }

    /**
     * 删除积分规则
     * @param idsDto
     * @return
     */
    @DeleteMapping
    public Result delete(@RequestBody IdsDto idsDto) {
        if (idsDto.getIds() != null && !idsDto.getIds().isEmpty()) {
            pointRulesService.removeBatchByIds(idsDto.getIds());
        }
        return Result.success();
    }

}
