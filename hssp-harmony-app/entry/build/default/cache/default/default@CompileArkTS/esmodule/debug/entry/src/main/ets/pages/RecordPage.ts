if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface RecordPage_Params {
    exchangeRecords?: ExchangeRecord[];
    selectedFilter?: string;
    isLoading?: boolean;
    apiClient?;
}
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import type { ExchangeRecord } from '../types/common';
import { AppColors, AppFonts, AppSpacing, AppBorderRadius } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
import AppShadows from "@normalized:N&&&entry/src/main/ets/config/AppShadows&";
export class RecordPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__exchangeRecords = new ObservedPropertyObjectPU([], this, "exchangeRecords");
        this.__selectedFilter = new ObservedPropertySimplePU('all' // all, points, steps
        , this, "selectedFilter");
        this.__isLoading = new ObservedPropertySimplePU(true, this, "isLoading");
        this.apiClient = ApiClient.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: RecordPage_Params) {
        if (params.exchangeRecords !== undefined) {
            this.exchangeRecords = params.exchangeRecords;
        }
        if (params.selectedFilter !== undefined) {
            this.selectedFilter = params.selectedFilter;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
    }
    updateStateVars(params: RecordPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__exchangeRecords.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedFilter.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__exchangeRecords.aboutToBeDeleted();
        this.__selectedFilter.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __exchangeRecords: ObservedPropertyObjectPU<ExchangeRecord[]>;
    get exchangeRecords() {
        return this.__exchangeRecords.get();
    }
    set exchangeRecords(newValue: ExchangeRecord[]) {
        this.__exchangeRecords.set(newValue);
    }
    private __selectedFilter: ObservedPropertySimplePU<string>; // all, points, steps
    get selectedFilter() {
        return this.__selectedFilter.get();
    }
    set selectedFilter(newValue: string) {
        this.__selectedFilter.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private apiClient;
    aboutToAppear() {
        this.loadExchangeRecords();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgColor);
        }, Column);
        // 筛选器头部
        this.buildFilterHeader.bind(this)();
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
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isLoading) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height(200);
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
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
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.backgroundColor(AppColors.bgCard);
                        Column.borderRadius(AppBorderRadius.radiusLg);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = (_item, index: number) => {
                            const record = _item;
                            this.buildRecordItem.bind(this)(record, index);
                        };
                        this.forEachUpdateFunction(elmtId, this.getFilteredRecords(), forEachItemGenFunction, undefined, true, false);
                    }, ForEach);
                    ForEach.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    buildFilterHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
            Row.backgroundColor(AppColors.bgCard);
            Row.shadow(AppShadows.shadowSm);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('兑换记录');
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('全部');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.selectedFilter === 'all' ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.selectedFilter === 'all' ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Button.onClick(() => {
                this.selectedFilter = 'all';
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('积分');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.selectedFilter === 'points' ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.selectedFilter === 'points' ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Button.onClick(() => {
                this.selectedFilter = 'points';
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('步数');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.selectedFilter === 'steps' ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.selectedFilter === 'steps' ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Button.onClick(() => {
                this.selectedFilter = 'steps';
            });
        }, Button);
        Button.pop();
        Row.pop();
        Row.pop();
    }
    buildRecordItem(record: ExchangeRecord, index: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(AppSpacing.spaceLg);
            Row.backgroundColor(index % 2 === 0 ? AppColors.bgColor : AppColors.bgCard);
            Row.borderRadius(AppBorderRadius.radiusBase);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 图标
            Column.create();
            // 图标
            Column.width(40);
            // 图标
            Column.height(40);
            // 图标
            Column.backgroundColor(record.type === 'points' ? AppColors.successLight : AppColors.primaryLight);
            // 图标
            Column.borderRadius(AppBorderRadius.radiusFull);
            // 图标
            Column.justifyContent(FlexAlign.Center);
            // 图标
            Column.alignItems(HorizontalAlign.Center);
            // 图标
            Column.margin({ right: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(record.type === 'points' ? '🔄' : '👣');
            Text.fontSize(24);
        }, Text);
        Text.pop();
        // 图标
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 内容
            Column.create();
            // 内容
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(record.type === 'points' ? '积分兑换' : '步数记录');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.formatDateTime(record.exchangeTime));
            Text.fontSize(AppFonts.fontSizeXs);
            Text.fontColor(AppColors.textSecondary);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        // 内容
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 数值
            Column.create();
            // 数值
            Column.alignItems(HorizontalAlign.End);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(record.type === 'points' ? `+${record.points}` : `${record.steps}`);
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(record.type === 'points' ? AppColors.successColor : AppColors.primaryColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(record.type === 'points' ? '积分' : '步');
            Text.fontSize(AppFonts.fontSizeXs);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        // 数值
        Column.pop();
        Row.pop();
    }
    private async loadExchangeRecords(): Promise<void> {
        this.isLoading = true;
        try {
            const response = await this.apiClient.getAllExchangeRecords();
            if (response.code === 1) {
                this.exchangeRecords = response.data;
            }
        }
        catch (error) {
            // 模拟数据
            await this.delay(500);
            const mockRecords: ExchangeRecord[] = [
                {
                    id: 1,
                    productId: 1,
                    productName: '运动手环',
                    points: 5000,
                    status: 1,
                    exchangeTime: new Date(Date.now() - 86400000 * 5).toISOString(),
                    type: 'points',
                    steps: 0,
                    description: '已发货'
                } as ExchangeRecord,
                {
                    id: 2,
                    productId: 3,
                    productName: '运动毛巾',
                    points: 800,
                    status: 2,
                    exchangeTime: new Date(Date.now() - 86400000 * 10).toISOString(),
                    type: 'points',
                    steps: 0,
                    description: '已完成'
                } as ExchangeRecord,
                {
                    id: 3,
                    productId: 0,
                    productName: '',
                    points: 0,
                    status: 1,
                    exchangeTime: new Date(Date.now() - 86400000 * 2).toISOString(),
                    type: 'steps',
                    steps: 5000,
                    description: '步数记录'
                } as ExchangeRecord
            ];
            // 按时间排序
            this.exchangeRecords = mockRecords.sort((a, b) => new Date(b.exchangeTime || '').getTime() - new Date(a.exchangeTime || '').getTime());
        }
        this.isLoading = false;
    }
    private getFilteredRecords(): ExchangeRecord[] {
        if (this.selectedFilter === 'all') {
            return this.exchangeRecords;
        }
        return this.exchangeRecords.filter(record => record.type === this.selectedFilter);
    }
    private formatDateTime(dateTimeStr: string | undefined): string {
        if (!dateTimeStr)
            return '';
        const date = new Date(dateTimeStr);
        return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
    }
    private delay(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    rerender() {
        this.updateDirtyElements();
    }
}
