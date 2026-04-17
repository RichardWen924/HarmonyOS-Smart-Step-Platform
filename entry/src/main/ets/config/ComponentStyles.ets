/**
 * 组件样式配置
 * 统一界面组件样式，确保视觉一致性
 */

import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppShadows
} from './DesignSystem'

// ==================== 按钮样式 ====================
class ButtonStyles {
  // 主要按钮
  static primary = {
    backgroundColor: AppColors.primaryColor,
    fontColor: Color.White,
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightMedium,
    borderRadius: AppBorderRadius.radiusBase,
    height: 48,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 次要按钮
  static secondary = {
    backgroundColor: AppColors.bgColor,
    fontColor: AppColors.textColor,
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightMedium,
    borderRadius: AppBorderRadius.radiusBase,
    border: { width: 1, color: AppColors.borderColor },
    height: 48,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 成功按钮
  static success = {
    backgroundColor: AppColors.successColor,
    fontColor: Color.White,
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightMedium,
    borderRadius: AppBorderRadius.radiusBase,
    height: 48,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 警告按钮
  static warning = {
    backgroundColor: AppColors.warningColor,
    fontColor: Color.White,
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightMedium,
    borderRadius: AppBorderRadius.radiusBase,
    height: 48,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 小尺寸按钮
  static small = {
    fontSize: AppFonts.fontSizeSm,
    height: 36,
    padding: { left: AppSpacing.spaceMd, right: AppSpacing.spaceMd }
  }

  // 大尺寸按钮
  static large = {
    fontSize: AppFonts.fontSizeLg,
    height: 56,
    padding: { left: AppSpacing.spaceXl, right: AppSpacing.spaceXl }
  }
}

// ==================== 卡片样式 ====================
class CardStyles {
  // 基础卡片
  static base = {
    backgroundColor: AppColors.bgCard,
    borderRadius: AppBorderRadius.radiusLg,
    shadow: AppShadows.shadowCard,
    padding: AppSpacing.space3Xl
  }

  // 小卡片
  static small = {
    backgroundColor: AppColors.bgCard,
    borderRadius: AppBorderRadius.radiusBase,
    shadow: AppShadows.shadowSm,
    padding: AppSpacing.spaceLg
  }

  // 大卡片
  static large = {
    backgroundColor: AppColors.bgCard,
    borderRadius: AppBorderRadius.radius2Xl,
    shadow: AppShadows.shadowLg,
    padding: AppSpacing.space4Xl
  }
}

// ==================== 输入框样式 ====================
class InputStyles {
  // 基础输入框
  static base = {
    backgroundColor: AppColors.bgColor,
    border: { width: 1, color: AppColors.borderColor },
    borderRadius: AppBorderRadius.radiusBase,
    fontSize: AppFonts.fontSizeBase,
    fontColor: AppColors.textColor,
    height: 52,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 错误状态输入框
  static error = {
    backgroundColor: AppColors.errorLight,
    border: { width: 1, color: AppColors.errorColor },
    borderRadius: AppBorderRadius.radiusBase,
    fontSize: AppFonts.fontSizeBase,
    fontColor: AppColors.errorColor,
    height: 52,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }

  // 成功状态输入框
  static success = {
    backgroundColor: AppColors.successLight,
    border: { width: 1, color: AppColors.successColor },
    borderRadius: AppBorderRadius.radiusBase,
    fontSize: AppFonts.fontSizeBase,
    fontColor: AppColors.successColor,
    height: 52,
    padding: { left: AppSpacing.spaceLg, right: AppSpacing.spaceLg }
  }
}

// ==================== 标签样式 ====================
class LabelStyles {
  // 标题标签
  static title = {
    fontSize: AppFonts.fontSize2Xl,
    fontWeight: AppFonts.fontWeightBold,
    fontColor: AppColors.titleColor
  }

  // 副标题标签
  static subtitle = {
    fontSize: AppFonts.fontSizeLg,
    fontWeight: AppFonts.fontWeightMedium,
    fontColor: AppColors.textColor
  }

  // 正文标签
  static body = {
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightRegular,
    fontColor: AppColors.textColor
  }

  // 次要标签
  static secondary = {
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightRegular,
    fontColor: AppColors.textSecondary
  }

  // 禁用标签
  static disabled = {
    fontSize: AppFonts.fontSizeBase,
    fontWeight: AppFonts.fontWeightRegular,
    fontColor: AppColors.textDisabled
  }
}

// ==================== 图标样式 ====================
class IconStyles {
  // 小图标
  static small = {
    fontSize: 16
  }

  // 中等图标
  static medium = {
    fontSize: 24
  }

  // 大图标
  static large = {
    fontSize: 32
  }

  // 超大图标
  static xlarge = {
    fontSize: 48
  }
}

// ==================== 间距样式 ====================
class SpacingStyles {
  // 内边距
  static padding = {
    small: AppSpacing.spaceLg,
    medium: AppSpacing.space3Xl,
    large: AppSpacing.space4Xl
  }

  // 外边距
  static margin = {
    small: AppSpacing.spaceSm,
    medium: AppSpacing.spaceLg,
    large: AppSpacing.space3Xl
  }

  // 组件间距
  static gap = {
    small: AppSpacing.spaceSm,
    medium: AppSpacing.spaceLg,
    large: AppSpacing.space2Xl
  }
}

// ==================== 阴影样式 ====================
class ShadowStyles {
  // 小阴影
  static small = AppShadows.shadowSm
  
  // 基础阴影
  static base = AppShadows.shadowBase
  
  // 大阴影
  static large = AppShadows.shadowLg
  
  // 卡片阴影
  static card = AppShadows.shadowCard
}

export {
  ButtonStyles,
  CardStyles,
  InputStyles,
  LabelStyles,
  IconStyles,
  SpacingStyles,
  ShadowStyles
}