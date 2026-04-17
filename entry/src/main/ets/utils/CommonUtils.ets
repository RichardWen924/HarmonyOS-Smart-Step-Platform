/**
 * 数据验证结果接口
 */
export interface ValidationResult {
  valid: boolean;
  message: string;
}

/**
 * 日期时间工具类
 */
export class DateUtils {
  // 格式化日期
  static formatDate(date: Date, format: string = 'yyyy-MM-dd'): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return format
      .replace('yyyy', String(year))
      .replace('MM', month)
      .replace('dd', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  }

  // 获取日期字符串 (YYYY-MM-DD)
  static getDateStr(date: Date = new Date()): string {
    return this.formatDate(date, 'yyyy-MM-dd');
  }

  // 获取时间字符串 (HH:mm:ss)
  static getTimeStr(date: Date = new Date()): string {
    return this.formatDate(date, 'HH:mm:ss');
  }

  // 获取相对时间描述
  static getRelativeTime(date: Date): string {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
      return '今天';
    } else if (days === 1) {
      return '昨天';
    } else if (days < 7) {
      return `${days}天前`;
    } else if (days < 30) {
      return `${Math.floor(days / 7)}周前`;
    } else if (days < 365) {
      return `${Math.floor(days / 30)}个月前`;
    } else {
      return `${Math.floor(days / 365)}年前`;
    }
  }

  // 判断是否是今天
  static isToday(date: Date): boolean {
    const today = new Date();
    return date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate();
  }

  // 判断是否是本周
  static isThisWeek(date: Date): boolean {
    const now = new Date();
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    return date.getTime() > oneWeekAgo.getTime();
  }

  // 判断是否是本月
  static isThisMonth(date: Date): boolean {
    const now = new Date();
    return date.getFullYear() === now.getFullYear() &&
      date.getMonth() === now.getMonth();
  }
}

/**
 * 数据验证工具类
 */
export class Validator {
  // 验证邮箱
  static isEmail(email: string): boolean {
    const reg = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return reg.test(email);
  }

  // 验证手机号 (中国大陆)
  static isPhone(phone: string): boolean {
    const reg = /^1[3-9]\d{9}$/;
    return reg.test(phone);
  }

  // 验证密码强度
  static validatePassword(password: string): ValidationResult {
    if (password.length < 6) {
      return { valid: false, message: '密码长度不能少于 6 位' };
    }
    if (password.length > 20) {
      return { valid: false, message: '密码长度不能超过 20 位' };
    }
    if (!/[a-zA-Z]/.test(password) || !/[0-9]/.test(password)) {
      return { valid: false, message: '密码必须包含字母和数字' };
    }
    return { valid: true, message: '密码格式正确' };
  }

  // 验证昵称
  static validateNickname(nickname: string): boolean {
    return nickname.length >= 2 && nickname.length <= 20;
  }

  // 去除 HTML 标签
  static stripHtml(html: string): string {
    return html.replace(/<[^>]*>/g, '');
  }

  // 转义特殊字符
  static escapeHtml(str: string): string {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}

/**
 * 数字格式化工具
 */
export class NumberUtils {
  // 格式化数字 (添加千分位)
  static formatNumber(num: number): string {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  // 格式化步数
  static formatSteps(steps: number): string {
    if (steps >= 10000) {
      return (steps / 10000).toFixed(1) + 'w';
    }
    return steps.toString();
  }

  // 格式化积分
  static formatPoints(points: number): string {
    return points.toString();
  }

  // 计算百分比
  static percentage(part: number, total: number, decimals: number = 0): string {
    if (total === 0) return '0%';
    return ((part / total) * 100).toFixed(decimals) + '%';
  }

  // 保留小数
  static toFixed(num: number, digits: number = 2): string {
    return num.toFixed(digits);
  }
}

/**
 * 存储工具类
 */
export class StorageUtils {
  private static prefix = 'smart_step_';

  // 保存数据
  static async save(key: string, value: Record<string, unknown> | string | number | boolean): Promise<boolean> {
    try {
      const fullKey = this.prefix + key;
      const stringValue = JSON.stringify(value);
      // 这里需要使用 preferences API，由于是工具类，提供接口供调用
      console.log(`Save ${fullKey}: ${stringValue}`);
      return true;
    } catch (error) {
      console.error('Save failed:', error);
      return false;
    }
  }

  // 获取数据
  static async load(key: string, defaultValue: unknown): Promise<unknown> {
    try {
      const fullKey = this.prefix + key;
      // 实际实现需要从 preferences 读取
      console.log(`Load ${fullKey}`);
      return defaultValue;
    } catch (error) {
      console.error('Load failed:', error);
      return defaultValue;
    }
  }

  // 删除数据
  static async remove(key: string): Promise<boolean> {
    try {
      const fullKey = this.prefix + key;
      console.log(`Remove ${fullKey}`);
      return true;
    } catch (error) {
      console.error('Remove failed:', error);
      return false;
    }
  }

  // 清空所有数据
  static async clear(): Promise<boolean> {
    try {
      console.log('Clear all storage');
      return true;
    } catch (error) {
      console.error('Clear failed:', error);
      return false;
    }
  }
}

/**
 * 随机数工具
 */
export class RandomUtils {
  // 生成随机整数
  static randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  // 生成随机字符串
  static randomString(length: number = 6): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  // 生成随机颜色
  static randomColor(): string {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
      color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
  }

  // 生成随机步数 (用于模拟运动)
  static randomSteps(min: number = 100, max: number = 500): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
}
