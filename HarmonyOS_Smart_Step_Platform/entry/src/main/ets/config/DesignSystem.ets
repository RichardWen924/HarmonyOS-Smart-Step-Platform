/**
 * 运动应用设计系统
 * 参考华为运动健康和Keep的设计风格
 */

// ==================== 色彩系统 ====================
class AppColors {
  // 主色调 - 活力蓝（参考华为运动健康）
  static primaryColor = '#1677FF'
  static primaryLight = '#E6F7FF'
  static primaryDark = '#0958D9'
  
  // 功能色
  static successColor = '#52C41A'
  static successLight = '#F6FFED'
  static warningColor = '#FAAD14'
  static warningLight = '#FFFBE6'
  static errorColor = '#FF4D4F'
  static errorLight = '#FFF2F0'
  
  // 中性色
  static titleColor = '#262626'
  static textColor = '#595959'
  static textSecondary = '#8C8C8C'
  static textDisabled = '#BFBFBF'
  static borderColor = '#D9D9D9'
  static dividerColor = '#F0F0F0'
  static bgColor = '#F5F5F5'
  static bgCard = '#FFFFFF'
}

// ==================== 字体系统 ====================
class AppFonts {
  // 字重
  static fontWeightLight = FontWeight.Lighter
  static fontWeightRegular = FontWeight.Normal
  static fontWeightMedium = FontWeight.Medium
  static fontWeightBold = FontWeight.Bold
  
  // 字号（基于8px网格系统）
  static fontSizeXs = 10
  static fontSizeSm = 12
  static fontSizeBase = 14
  static fontSizeLg = 16
  static fontSizeXl = 18
  static fontSize2Xl = 20
  static fontSize3Xl = 24
  static fontSize4Xl = 28
  static fontSize5Xl = 32
  static fontSize6Xl = 48
  static fontSize7Xl = 56
}

// ==================== 间距系统 ====================
class AppSpacing {
  // 基于8px网格系统
  static spaceXs = 4
  static spaceSm = 8
  static spaceMd = 12
  static spaceLg = 16
  static spaceXl = 20
  static space2Xl = 24
  static space3Xl = 32
  static space4Xl = 40
  static space5Xl = 48
  static space6Xl = 56
  static space7Xl = 64
}

// ==================== 圆角系统 ====================
class AppBorderRadius {
  static radiusSm = 4
  static radiusBase = 8
  static radiusLg = 12
  static radiusXl = 16
  static radius2Xl = 20
  static radius3Xl = 24
  static radiusFull = 999
}

// ==================== 图标系统 ====================
class AppIcons {
  // 运动相关图标（使用emoji，实际项目中可替换为图标字体）
  static home = '🏠'
  static trend = '📊'
  static mall = '🛒'
  static record = '📝'
  static profile = '👤'
  static ranking = '🏆'
  static steps = '👣'
  static points = '🪙'
  static target = '🎯'
  static trophy = '🏅'
  static heart = '❤️'
  static fire = '🔥'
  static clock = '⏰'
  static calendar = '📅'
  static settings = '⚙️'
  static notification = '🔔'
  static security = '🔐'
  static info = 'ℹ️'
  static document = '📄'
  static privacy = '🔒'
  static logout = '🚪'
  static network = '📡'
  
  // 运动类型图标
  static walking = '🚶'
  static running = '🏃'
  static cycling = '🚴'
  static swimming = '🏊'
  static yoga = '🧘'
  static gym = '💪'
}

// ==================== 动画配置 ====================
class AppAnimations {
  // 动画时长（毫秒）
  static durationFast = 200
  static durationBase = 300
  static durationSlow = 500
}

export {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppAnimations
}