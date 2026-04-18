package com.hssp.model.mall.dto;

import lombok.Data;
import java.io.Serializable;

@Data
public class MallGoodsDto implements Serializable {
    private Long id;
    private String goodsName;
    private Integer requiredPoints;
    private String coverUrl;
    private Integer displayNum;
}
