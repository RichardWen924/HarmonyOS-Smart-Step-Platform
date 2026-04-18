/**
 * 运动应用设计系统
 * 优化视觉层次，增强简洁性和用户体验
 */

// ==================== 色彩系统 ====================
class AppColors {
  // 主色调 - 优化蓝色调，增强视觉层次
  static primaryColor: Color = 0x007AFF
  static primaryLight: Color = 0xE8F4FF
  static primaryDark: Color = 0x0056CC
  
  // 功能色 - 优化对比度和饱和度
  static successColor: Color = 0x10B981
  static successLight: Color = 0xDCFCE7
  static warningColor: Color = 0xF59E0B
  static warningLight: Color = 0xFEF3C7
  static errorColor: Color = 0xEF4444
  static errorLight: Color = 0xFEE2E2
  
  // 中性色 - 优化层级，增强可读性
  static titleColor: Color = 0x1E293B
  static textColor: Color = 0x334155
  static textSecondary: Color = 0x64748B
  static textDisabled: Color = 0x94A3B8
  static borderColor: Color = 0xE2E8F0
  static dividerColor: Color = 0xF1F5F9
  static bgColor: Color = 0xFAFBFC
  static bgCard: Color = 0xFFFFFF
  
  // 运动主题色 - 优化视觉一致性
  static sportGreen: Color = 0x10B981
  static sportBlue: Color = 0x007AFF
  static sportOrange: Color = 0xF59E0B
  
  // 新增渐变色
  static gradientStart: Color = 0x007AFF
  static gradientEnd: Color = 0x00D4FF
  
  // 强调色
  static accentColor: Color = 0xEC4899
}

// ==================== 字体系统 ====================
class AppFonts {
  // 字重
  static fontWeightLight = FontWeight.Lighter
  static fontWeightRegular = FontWeight.Normal
  static fontWeightMedium = FontWeight.Medium
  static fontWeightBold = FontWeight.Bold
  
  // 字号（优化对比度，增强可读性）
  static fontSizeXs = 11
  static fontSizeSm = 13
  static fontSizeBase = 15
  static fontSizeLg = 17
  static fontSizeXl = 19
  static fontSize2Xl = 21
  static fontSize3Xl = 24
  static fontSize4Xl = 28
  static fontSize5Xl = 32
  static fontSize6Xl = 40
  static fontSize7Xl = 48
  
  // 新增行高配置
  static lineHeightTight = 1.2
  static lineHeightNormal = 1.5
  static lineHeightLoose = 1.8
}

// ==================== 间距系统 ====================
class AppSpacing {
  // 基于4px网格系统，增强节奏感
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
  
  // 新增布局间距
  static layoutMargin = 16
  static sectionMargin = 32
  static componentMargin = 12
}

// ==================== 圆角系统 ====================
class AppBorderRadius {
  // 优化圆角值，增强现代感
  static radiusSm = 6
  static radiusBase = 12
  static radiusLg = 16
  static radiusXl = 20
  static radius2Xl = 24
  static radius3Xl = 32
  static radiusFull = 999
}

// ==================== 图标系统 ====================
class AppIcons {
  // 优化图标选择，增强视觉一致性
  static home = '🏠'
  static trend = '📈'
  static mall = '🛍️'
  static record = '📋'
  static profile = '👤'
  static ranking = '🏆'
  static steps = '👣'
  static points = '⭐'
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
  static refresh = '🔄'
  
  // 运动类型图标
  static walking = '🚶'
  static running = '🏃'
  static cycling = '🚴'
  static swimming = '🏊'
  static yoga = '🧘'
  static gym = '💪'
  
  // 新增装饰图标
  static sparkle = '✨'
  static star = '⭐'
  static medal = '🏅'
  static crown = '👑'
}

// ==================== 动画配置 ====================
class AppAnimations {
  // 动画时长（毫秒）- 优化响应速度
  static durationFast = 150
  static durationBase = 250
  static durationSlow = 400
  
  // 新增动画曲线
  static easeInOut = Curve.EaseInOut
  static easeOut = Curve.EaseOut
  static easeIn = Curve.EaseIn
}

// ==================== 阴影配置 ====================
interface ShadowEffect {
  radius: number;
  color: ResourceColor;
  offsetX: number;
  offsetY: number;
}

class AppShadows {
  // 阴影配置接口
  static shadowSm: ShadowEffect = {
    radius: 4,
    color: '#0000000A',
    offsetX: 0,
    offsetY: 2
  }
  
  static shadowBase: ShadowEffect = {
    radius: 8,
    color: '#00000014',
    offsetX: 0,
    offsetY: 4
  }
  
  static shadowLg: ShadowEffect = {
    radius: 16,
    color: '#0000001A',
    offsetX: 0,
    offsetY: 8
  }
  
  // 新增阴影变体
  static shadowCard: ShadowEffect = {
    radius: 12,
    color: '#0000000F',
    offsetX: 0,
    offsetY: 6
  }
}

export {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppAnimations,
  AppShadows
}