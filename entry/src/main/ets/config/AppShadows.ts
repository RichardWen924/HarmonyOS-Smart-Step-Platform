/**
 * 阴影配置 - 独立文件确保类型安全
 */

// 阴影选项接口
interface ShadowOptions {
  radius: number
  color: number | string
  offsetX: number
  offsetY: number
}

// 阴影配置类
class AppShadows {
  static shadowSm: ShadowOptions = {
    radius: 4,
    color: 0x1A000000,
    offsetX: 0,
    offsetY: 2
  }
  
  static shadowBase: ShadowOptions = {
    radius: 8,
    color: 0x1A000000,
    offsetX: 0,
    offsetY: 4
  }
  
  static shadowLg: ShadowOptions = {
    radius: 16,
    color: 0x1A000000,
    offsetX: 0,
    offsetY: 8
  }
  
  static shadowXl: ShadowOptions = {
    radius: 24,
    color: 0x1A000000,
    offsetX: 0,
    offsetY: 12
  }
}

export default AppShadows