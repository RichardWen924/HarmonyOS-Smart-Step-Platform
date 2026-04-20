package com.hssp.model.mall.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

@Data
@TableName("mall_goods")
public class MallGoods implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private String goodsName;

    private Integer requiredPoints;

    private String coverUrl;

    private Integer displayNum;

    private Integer stock;  // 库存数量

    private Integer isDeleted;

    private Date createTime;

    private Date updateTime;
}
