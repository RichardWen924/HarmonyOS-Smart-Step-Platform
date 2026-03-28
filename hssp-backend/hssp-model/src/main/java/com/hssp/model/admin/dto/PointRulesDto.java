package com.hssp.model.admin.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.hssp.common.admin.PointRules_Status;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PointRulesDto {
    private Long id;
    private String ruleName;
    private Integer stepsRequired;
    private Integer pointsAwarded;
    @JsonProperty("isActive")
    private PointRules_Status isActive;
}
