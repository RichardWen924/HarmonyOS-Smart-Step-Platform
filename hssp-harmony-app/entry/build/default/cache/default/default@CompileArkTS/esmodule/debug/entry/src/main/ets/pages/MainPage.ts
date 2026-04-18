if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HomePage_Params {
    todaySteps?: number;
    isSimulating?: boolean;
    showManualInputDialog?: boolean;
    manualInputValue?: string;
    stateStore?;
    apiClient?;
}
interface MainPage_Params {
    currentTabIndex?: number;
    todaySteps?: number;
    totalPoints?: number;
    userInfo?: UserInfo | null;
    stateStore?;
    apiClient?;
}
import router from "@ohos:router";
import promptAction from "@ohos:promptAction";
import StateStore from "@normalized:N&&&entry/src/main/ets/services/StateStore&";
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import type { UserInfo } from '../types/common';
import { AppColors, AppFonts, AppSpacing, AppBorderRadius, AppIcons } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
import AppShadows from "@normalized:N&&&entry/src/main/ets/config/AppShadows&";
import { TrendPage } from "@normalized:N&&&entry/src/main/ets/pages/TrendPage&";
import { RecordPage } from "@normalized:N&&&entry/src/main/ets/pages/RecordPage&";
enum TabIndex {
    HOME = 0,
    TREND = 1,
    MALL = 2,
    RECORD = 3,
    PROFILE = 4
}
class MainPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentTabIndex = new ObservedPropertySimplePU(0, this, "currentTabIndex");
        this.__todaySteps = new ObservedPropertySimplePU(0, this, "todaySteps");
        this.__totalPoints = new ObservedPropertySimplePU(0, this, "totalPoints");
        this.__userInfo = new ObservedPropertyObjectPU(null, this, "userInfo");
        this.stateStore = StateStore;
        this.apiClient = ApiClient.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MainPage_Params) {
        if (params.currentTabIndex !== undefined) {
            this.currentTabIndex = params.currentTabIndex;
        }
        if (params.todaySteps !== undefined) {
            this.todaySteps = params.todaySteps;
        }
        if (params.totalPoints !== undefined) {
            this.totalPoints = params.totalPoints;
        }
        if (params.userInfo !== undefined) {
            this.userInfo = params.userInfo;
        }
        if (params.stateStore !== undefined) {
            this.stateStore = params.stateStore;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
    }
    updateStateVars(params: MainPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentTabIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__todaySteps.purgeDependencyOnElmtId(rmElmtId);
        this.__totalPoints.purgeDependencyOnElmtId(rmElmtId);
        this.__userInfo.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentTabIndex.aboutToBeDeleted();
        this.__todaySteps.aboutToBeDeleted();
        this.__totalPoints.aboutToBeDeleted();
        this.__userInfo.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentTabIndex: ObservedPropertySimplePU<number>;
    get currentTabIndex() {
        return this.__currentTabIndex.get();
    }
    set currentTabIndex(newValue: number) {
        this.__currentTabIndex.set(newValue);
    }
    private __todaySteps: ObservedPropertySimplePU<number>;
    get todaySteps() {
        return this.__todaySteps.get();
    }
    set todaySteps(newValue: number) {
        this.__todaySteps.set(newValue);
    }
    private __totalPoints: ObservedPropertySimplePU<number>;
    get totalPoints() {
        return this.__totalPoints.get();
    }
    set totalPoints(newValue: number) {
        this.__totalPoints.set(newValue);
    }
    private __userInfo: ObservedPropertyObjectPU<UserInfo | null>;
    get userInfo() {
        return this.__userInfo.get();
    }
    set userInfo(newValue: UserInfo | null) {
        this.__userInfo.set(newValue);
    }
    private stateStore;
    private apiClient;
    aboutToAppear() {
        this.loadUserData();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgColor);
        }, Column);
        // 顶部标题栏
        this.buildHeader.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 内容区域
            Stack.create();
            // 内容区域
            Stack.layoutWeight(1);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 首页
            if (this.currentTabIndex === TabIndex.HOME) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        __Common__.create();
                        __Common__.width('100%');
                        __Common__.height('100%');
                    }, __Common__);
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new HomePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 49, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "HomePage" });
                    }
                    __Common__.pop();
                });
            }
            // 趋势页 - 使用独立的TrendPage组件
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 趋势页 - 使用独立的TrendPage组件
            if (this.currentTabIndex === TabIndex.TREND) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        __Common__.create();
                        __Common__.width('100%');
                        __Common__.height('100%');
                    }, __Common__);
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new TrendPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 56, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "TrendPage" });
                    }
                    __Common__.pop();
                });
            }
            // 商城页
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 商城页
            if (this.currentTabIndex === TabIndex.MALL) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // MallPage组件暂时使用空页面
                        Column.create();
                        // MallPage组件暂时使用空页面
                        Column.width('100%');
                        // MallPage组件暂时使用空页面
                        Column.height('100%');
                        // MallPage组件暂时使用空页面
                        Column.justifyContent(FlexAlign.Center);
                        // MallPage组件暂时使用空页面
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('🛒 积分商城');
                        Text.fontSize(AppFonts.fontSize2Xl);
                        Text.fontColor(AppColors.titleColor);
                        Text.fontWeight(AppFonts.fontWeightBold);
                        Text.margin({ bottom: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('商品兑换功能开发中');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textSecondary);
                    }, Text);
                    Text.pop();
                    // MallPage组件暂时使用空页面
                    Column.pop();
                });
            }
            // 记录页
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 记录页
            if (this.currentTabIndex === TabIndex.RECORD) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        __Common__.create();
                        __Common__.width('100%');
                        __Common__.height('100%');
                    }, __Common__);
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new RecordPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 83, col: 11 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "RecordPage" });
                    }
                    __Common__.pop();
                });
            }
            // 个人中心页 - 使用路由跳转
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 个人中心页 - 使用路由跳转
            if (this.currentTabIndex === TabIndex.PROFILE) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height('100%');
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('👤 个人中心');
                        Text.fontSize(AppFonts.fontSize2Xl);
                        Text.fontColor(AppColors.titleColor);
                        Text.fontWeight(AppFonts.fontWeightBold);
                        Text.margin({ bottom: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('点击下方Tab栏的"我的"查看个人中心');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textSecondary);
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // 内容区域
        Stack.pop();
        // 底部 Tab 导航
        this.buildTabBar.bind(this)();
        Column.pop();
    }
    // 构建顶部标题栏
    buildHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
            Row.backgroundColor(AppColors.bgCard);
            Row.shadow(AppShadows.shadowSm);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getTabTitle());
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.titleColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 显示用户积分
            if (this.totalPoints > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
                        Row.backgroundColor(AppColors.warningLight);
                        Row.borderRadius(AppBorderRadius.radiusFull);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(AppIcons.points);
                        Text.fontSize(AppFonts.fontSizeLg);
                        Text.margin({ right: AppSpacing.spaceXs });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.totalPoints.toLocaleString());
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.fontColor(AppColors.warningColor);
                    }, Text);
                    Text.pop();
                    Row.pop();
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
    // 构建底部 Tab 栏
    buildTabBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(68);
            Row.backgroundColor(AppColors.bgCard);
            Row.shadow(AppShadows.shadowSm);
            Row.justifyContent(FlexAlign.SpaceAround);
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        // Tab 1: 首页
        this.buildTabItem.bind(this)(AppIcons.home, '首页', TabIndex.HOME);
        // Tab 2: 趋势
        this.buildTabItem.bind(this)(AppIcons.trend, '趋势', TabIndex.TREND);
        // Tab 3: 商城
        this.buildTabItem.bind(this)(AppIcons.mall, '商城', TabIndex.MALL);
        // Tab 4: 记录
        this.buildTabItem.bind(this)(AppIcons.record, '记录', TabIndex.RECORD);
        // Tab 5: 我的 - 跳转到个人中心页面
        this.buildTabItem.bind(this)(AppIcons.profile, '我的', TabIndex.PROFILE, true);
        Row.pop();
    }
    // 构建 Tab 项
    buildTabItem(icon: string, label: string, index: TabIndex, isProfile: boolean = false, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(60);
            Column.height(50);
            Column.justifyContent(FlexAlign.Center);
            Column.onClick(() => {
                if (isProfile) {
                    // 跳转到个人中心页面
                    router.pushUrl({
                        url: 'pages/ProfilePage'
                    });
                }
                else {
                    this.currentTabIndex = index;
                }
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(icon);
            Text.fontSize(24);
            Text.margin({ bottom: AppSpacing.spaceXs });
            Text.fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(label);
            Text.fontSize(AppFonts.fontSizeXs);
            Text.fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary);
            Text.fontWeight(this.currentTabIndex === index ? AppFonts.fontWeightMedium : AppFonts.fontWeightRegular);
        }, Text);
        Text.pop();
        Column.pop();
    }
    // 获取当前 Tab 标题
    private getTabTitle(): string {
        const titles = ['运动健康', '步数趋势', '积分商城', '兑换记录', '个人中心'];
        return titles[this.currentTabIndex];
    }
    // 加载用户数据
    private async loadUserData(): Promise<void> {
        try {
            const userInfo = await this.stateStore.getUserInfo();
            this.userInfo = userInfo;
            this.todaySteps = this.stateStore.todaySteps;
            this.totalPoints = userInfo.totalPoints;
            // 从服务器获取最新积分
            const pointsData = await this.apiClient.getUserPoints();
            if (pointsData.code === 1) {
                this.totalPoints = pointsData.data.totalPoints;
                await this.stateStore.updatePoints(pointsData.data.totalPoints, pointsData.data.remainingSteps);
            }
        }
        catch (error) {
            console.error('Failed to load user data:', error);
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MainPage";
    }
}
class HomePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__todaySteps = new ObservedPropertySimplePU(0, this, "todaySteps");
        this.__isSimulating = new ObservedPropertySimplePU(false, this, "isSimulating");
        this.__showManualInputDialog = new ObservedPropertySimplePU(false, this, "showManualInputDialog");
        this.__manualInputValue = new ObservedPropertySimplePU('', this, "manualInputValue");
        this.stateStore = StateStore;
        this.apiClient = ApiClient.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HomePage_Params) {
        if (params.todaySteps !== undefined) {
            this.todaySteps = params.todaySteps;
        }
        if (params.isSimulating !== undefined) {
            this.isSimulating = params.isSimulating;
        }
        if (params.showManualInputDialog !== undefined) {
            this.showManualInputDialog = params.showManualInputDialog;
        }
        if (params.manualInputValue !== undefined) {
            this.manualInputValue = params.manualInputValue;
        }
        if (params.stateStore !== undefined) {
            this.stateStore = params.stateStore;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
    }
    updateStateVars(params: HomePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__todaySteps.purgeDependencyOnElmtId(rmElmtId);
        this.__isSimulating.purgeDependencyOnElmtId(rmElmtId);
        this.__showManualInputDialog.purgeDependencyOnElmtId(rmElmtId);
        this.__manualInputValue.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__todaySteps.aboutToBeDeleted();
        this.__isSimulating.aboutToBeDeleted();
        this.__showManualInputDialog.aboutToBeDeleted();
        this.__manualInputValue.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __todaySteps: ObservedPropertySimplePU<number>;
    get todaySteps() {
        return this.__todaySteps.get();
    }
    set todaySteps(newValue: number) {
        this.__todaySteps.set(newValue);
    }
    private __isSimulating: ObservedPropertySimplePU<boolean>;
    get isSimulating() {
        return this.__isSimulating.get();
    }
    set isSimulating(newValue: boolean) {
        this.__isSimulating.set(newValue);
    }
    private __showManualInputDialog: ObservedPropertySimplePU<boolean>;
    get showManualInputDialog() {
        return this.__showManualInputDialog.get();
    }
    set showManualInputDialog(newValue: boolean) {
        this.__showManualInputDialog.set(newValue);
    }
    private __manualInputValue: ObservedPropertySimplePU<string>;
    get manualInputValue() {
        return this.__manualInputValue.get();
    }
    set manualInputValue(newValue: string) {
        this.__manualInputValue.set(newValue);
    }
    private stateStore;
    private apiClient;
    aboutToAppear() {
        this.loadStepData();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.scrollable(ScrollDirection.Vertical);
            Scroll.layoutWeight(1);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.spaceLg);
        }, Column);
        // 今日步数卡片
        this.buildStepCard.bind(this)();
        // 快捷功能
        this.buildQuickActions.bind(this)();
        // 排行榜入口
        this.buildRankingEntry.bind(this)();
        Column.pop();
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 手动输入弹窗
            if (this.showManualInputDialog) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.buildManualInputDialog.bind(this)();
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
    buildStepCard(parent = null) {
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
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('今日步数');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(AppIcons.steps);
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.primaryColor);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.todaySteps.toLocaleString());
            Text.fontSize(AppFonts.fontSize7Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('步');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 目标完成度环
            Column.create();
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 背景环
            Circle.create();
            // 背景环
            Circle.width(80);
            // 背景环
            Circle.height(80);
            // 背景环
            Circle.fill(Color.Transparent);
            // 背景环
            Circle.stroke(AppColors.borderColor);
            // 背景环
            Circle.strokeWidth(4);
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 进度环
            Circle.create();
            // 进度环
            Circle.width(80);
            // 进度环
            Circle.height(80);
            // 进度环
            Circle.fill(Color.Transparent);
            // 进度环
            Circle.stroke(AppColors.primaryColor);
            // 进度环
            Circle.strokeWidth(4);
            // 进度环
            Circle.strokeDashArray([Math.PI * 80 * (Math.min(this.todaySteps, 10000) / 10000), Math.PI * 80]);
            // 进度环
            Circle.strokeDashOffset(0);
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${Math.min(Math.round(this.todaySteps / 100), 100)}`);
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('%');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        Column.pop();
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('目标进度');
            Text.fontSize(AppFonts.fontSizeXs);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        // 目标完成度环
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 进度条和目标
            Column.create();
            // 进度条和目标
            Column.width('100%');
            // 进度条和目标
            Column.margin({ bottom: AppSpacing.space2Xl });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.margin({ bottom: AppSpacing.spaceSm });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('目标：10,000 步');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${Math.min(this.todaySteps, 10000).toLocaleString()}/10,000`);
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.primaryColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Progress.create({ value: Math.min(this.todaySteps, 10000), total: 10000 });
            Progress.width('100%');
            Progress.height(8);
            Progress.color(AppColors.primaryColor);
            Progress.backgroundColor(AppColors.borderColor);
            Progress.borderRadius(AppBorderRadius.radiusFull);
        }, Progress);
        // 进度条和目标
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 按钮组
            Row.create();
            // 按钮组
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isSimulating ? '停止模拟' : '开始运动');
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(this.isSimulating ? AppColors.warningColor : AppColors.successColor);
            Button.fontColor(Color.White);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl });
            Button.enabled(!this.isSimulating);
            Button.onClick(() => {
                this.simulateWalking();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('上传数据');
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(AppColors.primaryColor);
            Button.fontColor(Color.White);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl });
            Button.onClick(() => {
                this.uploadSteps();
            });
        }, Button);
        Button.pop();
        // 按钮组
        Row.pop();
        Column.pop();
    }
    buildQuickActions(parent = null) {
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
            Text.create('快捷功能');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.margin({ bottom: AppSpacing.spaceLg });
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Grid.create();
            Grid.columnsTemplate('1fr 1fr');
            Grid.rowsGap(AppSpacing.spaceLg);
            Grid.columnsGap(AppSpacing.spaceLg);
        }, Grid);
        {
            const itemCreation2 = (elmtId, isInitialRender) => {
                GridItem.create(() => { }, false);
            };
            const observedDeepRender = () => {
                this.observeComponentCreation2(itemCreation2, GridItem);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height(100);
                    Column.padding(AppSpacing.spaceLg);
                    Column.backgroundColor(AppColors.successLight);
                    Column.borderRadius(AppBorderRadius.radiusBase);
                    Column.onClick(() => {
                        this.exchangePoints();
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('🔄');
                    Text.fontSize(32);
                    Text.margin({ bottom: AppSpacing.spaceSm });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('兑换积分');
                    Text.fontSize(AppFonts.fontSizeSm);
                    Text.fontColor(AppColors.textColor);
                    Text.fontWeight(AppFonts.fontWeightMedium);
                }, Text);
                Text.pop();
                Column.pop();
                GridItem.pop();
            };
            observedDeepRender();
        }
        {
            const itemCreation2 = (elmtId, isInitialRender) => {
                GridItem.create(() => { }, false);
            };
            const observedDeepRender = () => {
                this.observeComponentCreation2(itemCreation2, GridItem);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height(100);
                    Column.padding(AppSpacing.spaceLg);
                    Column.backgroundColor(AppColors.primaryLight);
                    Column.borderRadius(AppBorderRadius.radiusBase);
                    Column.onClick(() => {
                        this.manualInput();
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('📅');
                    Text.fontSize(32);
                    Text.margin({ bottom: AppSpacing.spaceSm });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('手动输入');
                    Text.fontSize(AppFonts.fontSizeSm);
                    Text.fontColor(AppColors.textColor);
                    Text.fontWeight(AppFonts.fontWeightMedium);
                }, Text);
                Text.pop();
                Column.pop();
                GridItem.pop();
            };
            observedDeepRender();
        }
        {
            const itemCreation2 = (elmtId, isInitialRender) => {
                GridItem.create(() => { }, false);
            };
            const observedDeepRender = () => {
                this.observeComponentCreation2(itemCreation2, GridItem);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height(100);
                    Column.padding(AppSpacing.spaceLg);
                    Column.backgroundColor(AppColors.warningLight);
                    Column.borderRadius(AppBorderRadius.radiusBase);
                    Column.onClick(() => {
                        promptAction.showToast({
                            message: '请点击下方Tab栏的"趋势"查看数据分析',
                            duration: 2000
                        });
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('📊');
                    Text.fontSize(32);
                    Text.margin({ bottom: AppSpacing.spaceSm });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('数据分析');
                    Text.fontSize(AppFonts.fontSizeSm);
                    Text.fontColor(AppColors.textColor);
                    Text.fontWeight(AppFonts.fontWeightMedium);
                }, Text);
                Text.pop();
                Column.pop();
                GridItem.pop();
            };
            observedDeepRender();
        }
        {
            const itemCreation2 = (elmtId, isInitialRender) => {
                GridItem.create(() => { }, false);
            };
            const observedDeepRender = () => {
                this.observeComponentCreation2(itemCreation2, GridItem);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height(100);
                    Column.padding(AppSpacing.spaceLg);
                    Column.backgroundColor(AppColors.bgColor);
                    Column.borderRadius(AppBorderRadius.radiusBase);
                    Column.onClick(() => {
                        promptAction.showToast({
                            message: '运动设置功能开发中',
                            duration: 2000
                        });
                    });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('⚙️');
                    Text.fontSize(32);
                    Text.margin({ bottom: AppSpacing.spaceSm });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create('运动设置');
                    Text.fontSize(AppFonts.fontSizeSm);
                    Text.fontColor(AppColors.textColor);
                    Text.fontWeight(AppFonts.fontWeightMedium);
                }, Text);
                Text.pop();
                Column.pop();
                GridItem.pop();
            };
            observedDeepRender();
        }
        Grid.pop();
        Column.pop();
    }
    buildRankingEntry(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
            Column.border({
                width: 2,
                color: AppColors.primaryLight
            });
            Column.onClick(() => {
                router.pushUrl({
                    url: 'pages/RankingPage'
                });
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🏆');
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.margin({ right: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('步数排行榜');
            Text.fontSize(AppFonts.fontSizeXl);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Row.backgroundColor(AppColors.primaryLight);
            Row.borderRadius(AppBorderRadius.radiusFull);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('查看完整榜单');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.primaryColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('➡️');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.margin({ left: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Row.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 增强排行榜前三名显示
            Row.create();
            // 增强排行榜前三名显示
            Row.width('100%');
            // 增强排行榜前三名显示
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const rank = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.layoutWeight(1);
                    Column.padding(AppSpacing.spaceLg);
                    Column.backgroundColor(AppColors.bgCard);
                    Column.borderRadius(AppBorderRadius.radiusLg);
                    Column.shadow(AppShadows.shadowBase);
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    // 奖牌背景
                    Stack.create();
                    // 奖牌背景
                    Stack.margin({ bottom: AppSpacing.spaceSm });
                }, Stack);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Circle.create();
                    Circle.width(60);
                    Circle.height(60);
                    Circle.fill(rank === 1 ? AppColors.warningLight :
                        rank === 2 ? AppColors.borderColor :
                            AppColors.successLight);
                }, Circle);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(rank === 1 ? '🥇' : rank === 2 ? '🥈' : '🥉');
                    Text.fontSize(28);
                }, Text);
                Text.pop();
                // 奖牌背景
                Stack.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.alignItems(HorizontalAlign.Center);
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`用户${rank}`);
                    Text.fontSize(AppFonts.fontSizeBase);
                    Text.fontColor(AppColors.textColor);
                    Text.fontWeight(AppFonts.fontWeightBold);
                    Text.maxLines(1);
                    Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                }, Text);
                Text.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(`${(30000 - rank * 5000).toLocaleString()}步`);
                    Text.fontSize(AppFonts.fontSizeSm);
                    Text.fontColor(rank === 1 ? AppColors.warningColor : AppColors.textSecondary);
                    Text.fontWeight(AppFonts.fontWeightMedium);
                }, Text);
                Text.pop();
                Column.pop();
                Column.pop();
            };
            this.forEachUpdateFunction(elmtId, [1, 2, 3], forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        // 增强排行榜前三名显示
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 添加激励文案
            Row.create();
            // 添加激励文案
            Row.width('100%');
            // 添加激励文案
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('💪 今日你上榜了吗？快来挑战吧！');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.fontWeight(AppFonts.fontWeightMedium);
        }, Text);
        Text.pop();
        // 添加激励文案
        Row.pop();
        Column.pop();
    }
    buildManualInputDialog(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 遮罩层
            Stack.create();
            // 遮罩层
            Stack.width('100%');
            // 遮罩层
            Stack.height('100%');
            // 遮罩层
            Stack.position({ x: 0, y: 0 });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 半透明遮罩
            Column.create();
            // 半透明遮罩
            Column.width('100%');
            // 半透明遮罩
            Column.height('100%');
            // 半透明遮罩
            Column.backgroundColor('#000000');
            // 半透明遮罩
            Column.opacity(0.5);
            // 半透明遮罩
            Column.onClick(() => {
                this.showManualInputDialog = false;
            });
        }, Column);
        // 半透明遮罩
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 弹窗内容
            Column.create();
            // 弹窗内容
            Column.width('80%');
            // 弹窗内容
            Column.padding(AppSpacing.space3Xl);
            // 弹窗内容
            Column.backgroundColor(AppColors.bgCard);
            // 弹窗内容
            Column.borderRadius(AppBorderRadius.radiusLg);
            // 弹窗内容
            Column.shadow(AppShadows.shadowLg);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('手动输入步数');
            Text.fontSize(AppFonts.fontSizeXl);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.margin({ bottom: AppSpacing.spaceLg });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('请输入今日步数（0-50000）');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ bottom: AppSpacing.spaceLg });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 输入框
            TextInput.create({
                placeholder: '例如：5000',
                text: this.manualInputValue
            });
            // 输入框
            TextInput.width('100%');
            // 输入框
            TextInput.height(50);
            // 输入框
            TextInput.backgroundColor(AppColors.bgColor);
            // 输入框
            TextInput.border({
                width: 1,
                color: AppColors.borderColor,
                radius: AppBorderRadius.radiusBase
            });
            // 输入框
            TextInput.padding(AppSpacing.spaceLg);
            // 输入框
            TextInput.fontSize(AppFonts.fontSizeBase);
            // 输入框
            TextInput.fontColor(AppColors.textColor);
            // 输入框
            TextInput.onChange((value: string) => {
                this.manualInputValue = value;
            });
            // 输入框
            TextInput.margin({ bottom: AppSpacing.spaceLg });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 按钮组
            Row.create();
            // 按钮组
            Row.width('100%');
            // 按钮组
            Row.height(50);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('取消');
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(AppColors.bgColor);
            Button.fontColor(AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radiusBase);
            Button.layoutWeight(1);
            Button.onClick(() => {
                this.showManualInputDialog = false;
                this.manualInputValue = '';
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('确定');
            Button.fontSize(AppFonts.fontSizeBase);
            Button.backgroundColor(AppColors.primaryColor);
            Button.fontColor(Color.White);
            Button.borderRadius(AppBorderRadius.radiusBase);
            Button.layoutWeight(1);
            Button.margin({ left: AppSpacing.spaceLg });
            Button.onClick(() => {
                this.handleManualInput();
            });
        }, Button);
        Button.pop();
        // 按钮组
        Row.pop();
        // 弹窗内容
        Column.pop();
        // 遮罩层
        Stack.pop();
    }
    private async loadStepData(): Promise<void> {
        this.todaySteps = this.stateStore.todaySteps;
    }
    private simulateWalking() {
        this.isSimulating = true;
        // 模拟每 2 秒增加 100-500 步
        const interval = setInterval(() => {
            const addSteps = Math.floor(Math.random() * 400) + 100;
            this.todaySteps += addSteps;
            this.stateStore.addSteps(addSteps);
            if (this.todaySteps >= 10000) {
                clearInterval(interval);
                this.isSimulating = false;
                promptAction.showToast({
                    message: '🎉 恭喜您完成今日目标！',
                    duration: 3000
                });
            }
        }, 2000);
        promptAction.showToast({
            message: '🚶 开始模拟走路...',
            duration: 1500
        });
    }
    private async uploadSteps(): Promise<void> {
        try {
            const response = await this.apiClient.uploadSteps(this.todaySteps, new Date().toISOString().split('T')[0]);
            if (response.code === 1) {
                promptAction.showToast({
                    message: '✅ 数据上传成功',
                    duration: 2000
                });
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            promptAction.showToast({
                message: '❌ 上传失败，请重试',
                duration: 2000
            });
        }
    }
    private async exchangePoints(): Promise<void> {
        if (this.todaySteps < 1000) {
            promptAction.showToast({
                message: '满 1000 步可兑换积分',
                duration: 2000
            });
            return;
        }
        try {
            const steps = Math.floor(this.todaySteps / 1000) * 1000;
            const response = await this.apiClient.exchangePoints(steps);
            if (response.code === 1) {
                this.todaySteps = response.data.remainingSteps;
                await this.stateStore.updateTodaySteps(this.todaySteps);
                promptAction.showToast({
                    message: `🎉 成功兑换${response.data.gainedPoints}积分`,
                    duration: 2000
                });
            }
        }
        catch (error) {
            promptAction.showToast({
                message: '❌ 兑换失败',
                duration: 2000
            });
        }
    }
    private manualInput(): void {
        this.showManualInputDialog = true;
    }
    private handleManualInput(): void {
        const inputValue = parseInt(this.manualInputValue);
        if (isNaN(inputValue) || inputValue < 0 || inputValue > 50000) {
            promptAction.showToast({
                message: '请输入有效的步数（0-50000）',
                duration: 2000
            });
            return;
        }
        this.todaySteps += inputValue;
        this.stateStore.addSteps(inputValue);
        this.showManualInputDialog = false;
        this.manualInputValue = '';
        promptAction.showToast({
            message: `✅ 成功添加 ${inputValue.toLocaleString()} 步`,
            duration: 2000
        });
    }
    rerender() {
        this.updateDirtyElements();
    }
}
registerNamedRoute(() => new MainPage(undefined, {}), "", { bundleName: "com.hssp.app", moduleName: "entry", pagePath: "pages/MainPage", pageFullPath: "entry/src/main/ets/pages/MainPage", integratedHsp: "false", moduleType: "followWithHap" });
