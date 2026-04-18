if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RankingPage_Params {
    currentPeriod?: PeriodType;
    rankings?: RankingItem[];
    userRank?: number;
    userSteps?: number;
    currentPage?: number;
    total?: number;
    isLoading?: boolean;
    apiClient?;
    pageSize?: number;
}
import promptAction from "@ohos:promptAction";
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import type { RankingItem, PageData, UserInfo } from '../types/common';
import { AppColors, AppFonts, AppSpacing, AppBorderRadius, AppIcons } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
import AppShadows from "@normalized:N&&&entry/src/main/ets/config/AppShadows&";
enum PeriodType {
    DAY = "day",
    WEEK = "week",
    MONTH = "month"
}
class RankingPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentPeriod = new ObservedPropertySimplePU(PeriodType.DAY, this, "currentPeriod");
        this.__rankings = new ObservedPropertyObjectPU([], this, "rankings");
        this.__userRank = new ObservedPropertySimplePU(0, this, "userRank");
        this.__userSteps = new ObservedPropertySimplePU(0, this, "userSteps");
        this.__currentPage = new ObservedPropertySimplePU(1, this, "currentPage");
        this.__total = new ObservedPropertySimplePU(0, this, "total");
        this.__isLoading = new ObservedPropertySimplePU(false, this, "isLoading");
        this.apiClient = ApiClient.getInstance();
        this.pageSize = 10;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RankingPage_Params) {
        if (params.currentPeriod !== undefined) {
            this.currentPeriod = params.currentPeriod;
        }
        if (params.rankings !== undefined) {
            this.rankings = params.rankings;
        }
        if (params.userRank !== undefined) {
            this.userRank = params.userRank;
        }
        if (params.userSteps !== undefined) {
            this.userSteps = params.userSteps;
        }
        if (params.currentPage !== undefined) {
            this.currentPage = params.currentPage;
        }
        if (params.total !== undefined) {
            this.total = params.total;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
        if (params.pageSize !== undefined) {
            this.pageSize = params.pageSize;
        }
    }
    updateStateVars(params: RankingPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentPeriod.purgeDependencyOnElmtId(rmElmtId);
        this.__rankings.purgeDependencyOnElmtId(rmElmtId);
        this.__userRank.purgeDependencyOnElmtId(rmElmtId);
        this.__userSteps.purgeDependencyOnElmtId(rmElmtId);
        this.__currentPage.purgeDependencyOnElmtId(rmElmtId);
        this.__total.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentPeriod.aboutToBeDeleted();
        this.__rankings.aboutToBeDeleted();
        this.__userRank.aboutToBeDeleted();
        this.__userSteps.aboutToBeDeleted();
        this.__currentPage.aboutToBeDeleted();
        this.__total.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentPeriod: ObservedPropertySimplePU<PeriodType>;
    get currentPeriod() {
        return this.__currentPeriod.get();
    }
    set currentPeriod(newValue: PeriodType) {
        this.__currentPeriod.set(newValue);
    }
    private __rankings: ObservedPropertyObjectPU<RankingItem[]>;
    get rankings() {
        return this.__rankings.get();
    }
    set rankings(newValue: RankingItem[]) {
        this.__rankings.set(newValue);
    }
    private __userRank: ObservedPropertySimplePU<number>;
    get userRank() {
        return this.__userRank.get();
    }
    set userRank(newValue: number) {
        this.__userRank.set(newValue);
    }
    private __userSteps: ObservedPropertySimplePU<number>;
    get userSteps() {
        return this.__userSteps.get();
    }
    set userSteps(newValue: number) {
        this.__userSteps.set(newValue);
    }
    private __currentPage: ObservedPropertySimplePU<number>;
    get currentPage() {
        return this.__currentPage.get();
    }
    set currentPage(newValue: number) {
        this.__currentPage.set(newValue);
    }
    private __total: ObservedPropertySimplePU<number>;
    get total() {
        return this.__total.get();
    }
    set total(newValue: number) {
        this.__total.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private apiClient;
    private pageSize: number;
    aboutToAppear() {
        this.loadRankings();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgColor);
        }, Column);
        // 顶部导航栏
        this.buildHeader.bind(this)();
        // 周期选择
        this.buildPeriodSelector.bind(this)();
        // 我的排名
        this.buildMyRanking.bind(this)();
        // 排行榜列表
        this.buildRankingList.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 加载更多
            if (this.rankings.length < this.total) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.buildLoadMore.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    // 构建头部
    buildHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
            Row.backgroundColor(AppColors.bgCard);
            Row.shadow(AppShadows.shadowSm);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${AppIcons.ranking} 排行榜`);
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.titleColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        Row.pop();
    }
    // 构建周期选择器
    buildPeriodSelector(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('选择周期');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceLg });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceAround);
        }, Row);
        this.buildPeriodButton.bind(this)('日榜', PeriodType.DAY);
        this.buildPeriodButton.bind(this)('周榜', PeriodType.WEEK);
        this.buildPeriodButton.bind(this)('月榜', PeriodType.MONTH);
        Row.pop();
        Column.pop();
    }
    // 构建周期按钮
    buildPeriodButton(label: string, period: PeriodType, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(label);
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(this.currentPeriod === period ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.currentPeriod === period ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl });
            Button.enabled(!this.isLoading);
            Button.onClick(() => {
                if (this.currentPeriod !== period) {
                    this.currentPeriod = period;
                    this.currentPage = 1;
                    this.loadRankings();
                }
            });
        }, Button);
        Button.pop();
    }
    // 构建我的排名
    buildMyRanking(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('我的排名');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.userRank > 0 ? `第${this.userRank}名` : '未上榜');
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.vertical(true);
            Divider.height(40);
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.getPeriodName()}步数`);
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.userSteps.toLocaleString());
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.successColor);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
    }
    // 构建排行榜列表
    buildRankingList(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.spaceLg);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isLoading && this.rankings.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 加载中
                        Column.create();
                        // 加载中
                        Column.width('100%');
                        // 加载中
                        Column.padding(AppSpacing.space5Xl);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.width(40);
                        LoadingProgress.height(40);
                        LoadingProgress.color(AppColors.primaryColor);
                    }, LoadingProgress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('加载中...');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textSecondary);
                        Text.margin({ top: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    // 加载中
                    Column.pop();
                });
            }
            else if (this.rankings.length === 0) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 空数据
                        Column.create();
                        // 空数据
                        Column.width('100%');
                        // 空数据
                        Column.padding(AppSpacing.space5Xl);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('📭');
                        Text.fontSize(48);
                        Text.margin({ bottom: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无排名数据');
                        Text.fontSize(AppFonts.fontSizeLg);
                        Text.fontColor(AppColors.textSecondary);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.margin({ bottom: AppSpacing.spaceSm });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('快去运动争取上榜吧！');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.textDisabled);
                    }, Text);
                    Text.pop();
                    // 空数据
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 排行榜列表
                        ForEach.create();
                        const forEachItemGenFunction = (_item, index: number) => {
                            const item = _item;
                            this.buildRankingItem.bind(this)(item, index);
                        };
                        this.forEachUpdateFunction(elmtId, this.rankings, forEachItemGenFunction, undefined, true, false);
                    }, ForEach);
                    // 排行榜列表
                    ForEach.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    // 构建排名项
    buildRankingItem(item: RankingItem, index: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(AppSpacing.spaceLg);
            Row.backgroundColor(AppColors.bgCard);
            Row.borderRadius(AppBorderRadius.radiusLg);
            Row.shadow(AppShadows.shadowSm);
            Row.margin({ bottom: AppSpacing.spaceSm });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 排名
            Column.create();
            // 排名
            Column.width(40);
            // 排名
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (item.rank <= 3) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.getRankMedal(item.rank));
                        Text.fontSize(28);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width(32);
                        Column.height(32);
                        Column.backgroundColor(AppColors.bgColor);
                        Column.borderRadius(AppBorderRadius.radiusFull);
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(item.rank.toString());
                        Text.fontSize(AppFonts.fontSizeLg);
                        Text.fontWeight(AppFonts.fontWeightBold);
                        Text.fontColor(AppColors.textSecondary);
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        // 排名
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 头像
            Column.create();
            // 头像
            Column.width(48);
            // 头像
            Column.height(48);
            // 头像
            Column.backgroundColor(AppColors.primaryLight);
            // 头像
            Column.borderRadius(AppBorderRadius.radiusFull);
            // 头像
            Column.justifyContent(FlexAlign.Center);
            // 头像
            Column.margin({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(AppIcons.profile);
            Text.fontSize(24);
        }, Text);
        Text.pop();
        // 头像
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 用户信息
            Column.create();
            // 用户信息
            Column.layoutWeight(1);
            // 用户信息
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(item.nickname || item.username);
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.fontColor(AppColors.titleColor);
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${item.totalSteps.toLocaleString()} 步`);
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        // 用户信息
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 勋章（前10名）
            if (item.rank <= 10) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.getRankBadge(item.rank));
                        Text.fontSize(20);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
    }
    // 构建加载更多
    buildLoadMore(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isLoading ? '加载中...' : '加载更多');
            Button.width('100%');
            Button.height(48);
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(AppColors.bgColor);
            Button.fontColor(AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radiusBase);
            Button.margin({ top: AppSpacing.spaceSm, bottom: AppSpacing.spaceLg });
            Button.enabled(!this.isLoading);
            Button.onClick(() => {
                this.loadMore();
            });
        }, Button);
        Button.pop();
    }
    // 获取周期名称
    private getPeriodName(): string {
        switch (this.currentPeriod) {
            case PeriodType.DAY:
                return '今日';
            case PeriodType.WEEK:
                return '本周';
            case PeriodType.MONTH:
                return '本月';
        }
    }
    // 获取奖牌图标
    private getRankMedal(rank: number): string {
        switch (rank) {
            case 1:
                return '🥇';
            case 2:
                return '🥈';
            case 3:
                return '🥉';
            default:
                return '';
        }
    }
    // 获取排名徽章
    private getRankBadge(rank: number): string {
        if (rank <= 3)
            return '🏆';
        if (rank <= 10)
            return '🎖️';
        return '';
    }
    // 加载排行榜数据
    private async loadRankings(): Promise<void> {
        this.isLoading = true;
        try {
            const response = await this.apiClient.getRankings(this.currentPeriod, this.currentPage, this.pageSize);
            if (response.code === 1) {
                const pageData: PageData<UserInfo> = response.data;
                // 将UserInfo转换为RankingItem
                this.rankings = pageData.list.map((userInfo: UserInfo, index: number) => {
                    const rankingItem: RankingItem = {
                        rank: (this.currentPage - 1) * this.pageSize + index + 1,
                        userId: userInfo.id,
                        username: userInfo.username,
                        nickname: userInfo.nickname,
                        totalSteps: userInfo.totalSteps,
                        avatar: userInfo.avatar
                    };
                    return rankingItem;
                });
                this.total = pageData.total;
                // 模拟用户排名（实际应从接口返回）
                this.userRank = Math.floor(Math.random() * 100) + 1;
                this.userSteps = Math.floor(Math.random() * 20000) + 5000;
            }
        }
        catch (error) {
            console.error('Failed to load rankings:', error);
            promptAction.showToast({
                message: '❌ 加载失败',
                duration: 2000
            });
        }
        finally {
            this.isLoading = false;
        }
    }
    // 加载更多
    private loadMore(): void {
        if (this.isLoading)
            return;
        const nextPage = this.currentPage + 1;
        const maxPage = Math.ceil(this.total / this.pageSize);
        if (nextPage > maxPage) {
            promptAction.showToast({
                message: '没有更多数据了',
                duration: 2000
            });
            return;
        }
        this.currentPage = nextPage;
        this.loadMoreData();
    }
    // 加载更多数据
    private async loadMoreData(): Promise<void> {
        this.isLoading = true;
        try {
            const response = await this.apiClient.getRankings(this.currentPeriod, this.currentPage, this.pageSize);
            if (response.code === 1) {
                const pageData: PageData<UserInfo> = response.data;
                // 将UserInfo转换为RankingItem
                const newRankings = pageData.list.map((userInfo: UserInfo, index: number) => {
                    const rankingItem: RankingItem = {
                        rank: (this.currentPage - 1) * this.pageSize + index + 1,
                        userId: userInfo.id,
                        username: userInfo.username,
                        nickname: userInfo.nickname,
                        totalSteps: userInfo.totalSteps,
                        avatar: userInfo.avatar
                    };
                    return rankingItem;
                });
                this.rankings = [...this.rankings, ...newRankings];
            }
        }
        catch (error) {
            console.error('Failed to load more rankings:', error);
        }
        finally {
            this.isLoading = false;
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "RankingPage";
    }
}
registerNamedRoute(() => new RankingPage(undefined, {}), "", { bundleName: "com.hssp.app", moduleName: "entry", pagePath: "pages/RankingPage", pageFullPath: "entry/src/main/ets/pages/RankingPage", integratedHsp: "false", moduleType: "followWithHap" });
