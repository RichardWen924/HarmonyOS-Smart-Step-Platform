import preferences from "@ohos:data.preferences";
import type { UserInfo, StepRecord, StepStatistics, PermissionStatus } from '../types/common';
const PREF_NAME = 'step_data_store';
// 用户信息类
export class UserInfoImpl implements UserInfo {
    id: number = 0;
    username: string = '';
    email: string = '';
    nickname: string = '';
    sex?: number = 0;
    avatar?: string = '';
    totalSteps: number = 0;
    totalPoints: number = 0;
    remainingSteps: number = 0;
    constructor(id: number = 0, username: string = '', email: string = '', nickname: string = '', sex: number = 0, totalSteps: number = 0, totalPoints: number = 0, remainingSteps: number = 0) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.nickname = nickname;
        this.sex = sex;
        this.totalSteps = totalSteps;
        this.totalPoints = totalPoints;
        this.remainingSteps = remainingSteps;
    }
}
// 步数记录类
export class StepRecordImpl implements StepRecord {
    id: number = 0;
    steps: number = 0;
    date: string = '';
    timestamp: string = '';
    constructor(id: number = 0, steps: number = 0, date: string = '', timestamp: string = '') {
        this.id = id;
        this.steps = steps;
        this.date = date;
        this.timestamp = timestamp;
    }
}
// 步数统计类
export class StepStatisticsImpl implements StepStatistics {
    todaySteps: number = 0;
    weekSteps: number = 0;
    monthSteps: number = 0;
    totalSteps: number = 0;
    avgDailySteps: number = 0;
    maxDailySteps: number = 0;
    minDailySteps: number = 0;
    lastUpdate: string = '';
    constructor(todaySteps: number = 0, weekSteps: number = 0, monthSteps: number = 0, totalSteps: number = 0, avgDailySteps: number = 0, maxDailySteps: number = 0, minDailySteps: number = 0, lastUpdate: string = '') {
        this.todaySteps = todaySteps;
        this.weekSteps = weekSteps;
        this.monthSteps = monthSteps;
        this.totalSteps = totalSteps;
        this.avgDailySteps = avgDailySteps;
        this.maxDailySteps = maxDailySteps;
        this.minDailySteps = minDailySteps;
        this.lastUpdate = lastUpdate;
    }
}
// 权限状态类
export class PermissionStatusImpl implements PermissionStatus {
    stepCounter: boolean = false;
    healthKit: boolean = false;
    location: boolean = false;
    notification: boolean = false;
    constructor(stepCounter: boolean = false, healthKit: boolean = false, location: boolean = false, notification: boolean = false) {
        this.stepCounter = stepCounter;
        this.healthKit = healthKit;
        this.location = location;
        this.notification = notification;
    }
}
// 步数数据结构
class StepData {
    steps: number = 0;
    todaySteps: number = 0;
    lastUpdate: string = '';
    constructor(steps: number = 0, todaySteps: number = 0, lastUpdate: string = '') {
        this.steps = steps;
        this.todaySteps = todaySteps;
        this.lastUpdate = lastUpdate;
    }
}
@Observed
class StateStore {
    private static instance: StateStore = new StateStore();
    private preferences: preferences.Preferences | null = null;
    private isInitialized: boolean = false;
    // 应用状态 - 使用 @Observed 装饰器以便响应式更新
    isLoggedIn: boolean = false;
    currentSteps: number = 0;
    todaySteps: number = 0;
    userInfo: UserInfo = new UserInfoImpl();
    stepStatistics: StepStatistics = new StepStatisticsImpl();
    permissionStatus: PermissionStatus = new PermissionStatusImpl();
    // Token 管理
    private token: string = '';
    // 私有构造函数
    private constructor() {
        // 构造函数中不初始化 preferences，由外部调用 initialize()
    }
    // 获取单例实例
    static getInstance(): StateStore {
        return StateStore.instance;
    }
    // 初始化（必须在应用启动时调用）
    async initialize(context: Context): Promise<boolean> {
        if (this.isInitialized) {
            console.log('StateStore already initialized');
            return true;
        }
        try {
            if (!context) {
                console.error('Context is null');
                return false;
            }
            this.preferences = await preferences.getPreferences(context, PREF_NAME);
            this.isInitialized = true;
            console.log('StateStore initialized successfully');
            // 自动加载已保存的数据
            await this.loadSavedData();
            return true;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error as Error | string | Record<string, string>);
            console.error('Failed to initialize StateStore:', errorMessage);
            return false;
        }
    }
    // 加载已保存的数据
    private async loadSavedData(): Promise<void> {
        if (!this.preferences)
            return;
        try {
            // 加载用户信息
            const id = await this.preferences.get('user_id', 0) as number;
            if (id > 0) {
                await this.getUserInfo();
            }
            // 加载步数数据
            await this.getStepData();
        }
        catch (error) {
            console.error('Failed to load saved data:', error);
        }
    }
    // 设置 Token
    setToken(token: string): void {
        this.token = token;
    }
    // 获取 Token
    getToken(): string {
        return this.token;
    }
    // 确保 preferences 已初始化（内部使用）
    private async ensureInitialized(): Promise<boolean> {
        if (!this.isInitialized || !this.preferences) {
            console.warn('StateStore not initialized. Call initialize() first.');
            return false;
        }
        return true;
    }
    // 保存用户信息
    async saveUserInfo(userInfo: UserInfo): Promise<boolean> {
        if (!await this.ensureInitialized()) {
            return false;
        }
        try {
            await this.preferences?.put('user_id', userInfo.id);
            await this.preferences?.put('username', userInfo.username);
            await this.preferences?.put('email', userInfo.email);
            await this.preferences?.put('nickname', userInfo.nickname);
            await this.preferences?.put('sex', userInfo.sex || 0);
            await this.preferences?.put('total_steps', userInfo.totalSteps);
            await this.preferences?.put('total_points', userInfo.totalPoints);
            await this.preferences?.put('remaining_steps', userInfo.remainingSteps);
            await this.preferences?.flush();
            this.userInfo = userInfo;
            this.isLoggedIn = true;
            return true;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error);
            console.error('Failed to save user info:', errorMessage);
            return false;
        }
    }
    // 获取用户信息
    async getUserInfo(): Promise<UserInfo> {
        if (!await this.ensureInitialized()) {
            return new UserInfoImpl();
        }
        try {
            const id = await this.preferences?.get('user_id', 0) as number;
            const username = await this.preferences?.get('username', '') as string;
            const email = await this.preferences?.get('email', '') as string;
            const nickname = await this.preferences?.get('nickname', '') as string;
            const sex = await this.preferences?.get('sex', 0) as number;
            const totalSteps = await this.preferences?.get('total_steps', 0) as number;
            const totalPoints = await this.preferences?.get('total_points', 0) as number;
            const remainingSteps = await this.preferences?.get('remaining_steps', 0) as number;
            const userInfo = new UserInfoImpl(id, username, email, nickname, sex, totalSteps, totalPoints, remainingSteps);
            this.userInfo = userInfo;
            this.isLoggedIn = id > 0;
            return userInfo;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error);
            console.error('Failed to get user info:', errorMessage);
            return new UserInfoImpl();
        }
    }
    // 保存步数数据
    async saveStepData(steps: number, lastUpdate: string): Promise<boolean> {
        if (!await this.ensureInitialized()) {
            return false;
        }
        try {
            await this.preferences?.put('current_steps', steps);
            await this.preferences?.put('today_steps', steps);
            await this.preferences?.put('last_step_update', lastUpdate);
            await this.preferences?.flush();
            this.currentSteps = steps;
            this.todaySteps = steps;
            return true;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error);
            console.error('Failed to save step data:', errorMessage);
            return false;
        }
    }
    // 获取步数数据
    async getStepData(): Promise<StepData> {
        if (!await this.ensureInitialized()) {
            return new StepData();
        }
        try {
            const steps = await this.preferences?.get('current_steps', 0) as number;
            const todaySteps = await this.preferences?.get('today_steps', 0) as number;
            const lastUpdate = await this.preferences?.get('last_step_update', '') as string;
            this.currentSteps = steps;
            this.todaySteps = todaySteps;
            const stepData = new StepData(steps, todaySteps, lastUpdate);
            return stepData;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error);
            console.error('Failed to get step data:', errorMessage);
            const defaultData = new StepData(0, 0, '');
            return defaultData;
        }
    }
    // 更新今日步数
    async updateTodaySteps(steps: number): Promise<boolean> {
        this.todaySteps = steps;
        this.currentSteps = steps;
        return await this.saveStepData(steps, new Date().toISOString());
    }
    // 增加步数
    async addSteps(steps: number): Promise<boolean> {
        const newSteps = this.todaySteps + steps;
        return await this.updateTodaySteps(newSteps);
    }
    // 更新积分
    async updatePoints(totalPoints: number, remainingSteps: number): Promise<boolean> {
        this.userInfo.totalPoints = totalPoints;
        this.userInfo.remainingSteps = remainingSteps;
        return await this.saveUserInfo(this.userInfo);
    }
    // 清除所有数据
    async clearAllData(): Promise<boolean> {
        if (!await this.ensureInitialized()) {
            return false;
        }
        try {
            await this.preferences?.clear();
            await this.preferences?.flush();
            this.isLoggedIn = false;
            this.currentSteps = 0;
            this.todaySteps = 0;
            this.userInfo = new UserInfoImpl();
            this.stepStatistics = new StepStatisticsImpl();
            this.permissionStatus = new PermissionStatusImpl();
            this.token = '';
            return true;
        }
        catch (error) {
            const errorMessage = this.getErrorMessage(error);
            console.error('Failed to clear data:', errorMessage);
            return false;
        }
    }
    // 登录方法
    async login(userInfo: UserInfo, token: string): Promise<boolean> {
        this.token = token;
        return await this.saveUserInfo(userInfo);
    }
    // 登出方法
    async logout(): Promise<boolean> {
        return await this.clearAllData();
    }
    // 获取步数历史记录（模拟数据）
    getStepHistory(days: number): StepRecord[] {
        const history: StepRecord[] = [];
        const today = new Date();
        for (let i = 0; i < days; i++) {
            const date = new Date(today);
            date.setDate(today.getDate() - i);
            const record = new StepRecordImpl(i, Math.floor(Math.random() * 15000) + 5000, date.toISOString().split('T')[0], date.toISOString());
            history.push(record);
        }
        return history.reverse();
    }
    // 计算统计数据
    calculateStatistics(records: StepRecord[]): StepStatistics {
        if (records.length === 0) {
            return new StepStatisticsImpl();
        }
        const totalSteps = records.reduce((sum, record) => sum + record.steps, 0);
        const avgSteps = Math.floor(totalSteps / records.length);
        const maxSteps = Math.max(...records.map(r => r.steps));
        const minSteps = Math.min(...records.map(r => r.steps));
        const stats = new StepStatisticsImpl(records[0]?.steps || 0, totalSteps, totalSteps, totalSteps, avgSteps, maxSteps, minSteps, new Date().toISOString());
        this.stepStatistics = stats;
        return stats;
    }
    // 安全的错误消息获取方法
    private getErrorMessage(error: Error | string | Record<string, string>): string {
        if (error instanceof Error) {
            return error.message;
        }
        if (typeof error === 'string') {
            return error;
        }
        const errorObj = error as Record<string, string>;
        if (errorObj.message && typeof errorObj.message === 'string') {
            return errorObj.message;
        }
        return 'Unknown error occurred';
    }
}
// 导出单例实例
export default StateStore.getInstance();
