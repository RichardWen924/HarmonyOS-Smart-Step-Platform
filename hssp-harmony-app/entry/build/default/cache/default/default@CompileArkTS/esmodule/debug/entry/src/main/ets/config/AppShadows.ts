/**
 * 阴影系统配置
 * 使用接口定义避免对象字面量问题
 */
// 阴影配置接口
interface ShadowConfig {
    radius: number;
    color: string;
    offsetX: number;
    offsetY: number;
}
// 阴影配置类
class AppShadows {
    // 小阴影
    static shadowSm: ShadowConfig = {
        radius: 4,
        color: '#00000014',
        offsetX: 0,
        offsetY: 2
    };
    // 基础阴影
    static shadowBase: ShadowConfig = {
        radius: 8,
        color: '#0000001A',
        offsetX: 0,
        offsetY: 4
    };
    // 大阴影
    static shadowLg: ShadowConfig = {
        radius: 16,
        color: '#0000001F',
        offsetX: 0,
        offsetY: 8
    };
}
export default AppShadows;
