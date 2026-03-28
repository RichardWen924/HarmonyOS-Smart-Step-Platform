package com.hssp.service.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hssp.model.admin.dto.LoginDto;
import com.hssp.model.admin.dto.RegisterDto;
import com.hssp.model.admin.po.Admin;
import com.hssp.service.mapper.AdminMapper;

public interface AdminService extends IService<Admin> {
    Boolean register(RegisterDto registerDto);
}
