if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface TrendPage_Params {
    stepRecords?: StepRecord[];
    totalSteps?: number;
    avgSteps?: number;
    maxSteps?: number;
    selectedPeriod?: number;
    isLoading?: boolean;
    chartData?: number[];
    chartLabels?: string[];
    apiClient?;
}
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import type { StepRecord } from '../types/common';
import { LineChart } from "@normalized:N&&&entry/src/main/ets/components/LineChart&";
import { AppColors, AppFonts, AppSpacing, AppBorderRadius } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
import AppShadows from "@normalized:N&&&entry/src/main/ets/config/AppShadows&";
export class TrendPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__stepRecords = new ObservedPropertyObjectPU([], this, "stepRecords");
        this.__totalSteps = new ObservedPropertySimplePU(0, this, "totalSteps");
        this.__avgSteps = new ObservedPropertySimplePU(0, this, "avgSteps");
        this.__maxSteps = new ObservedPropertySimplePU(0, this, "maxSteps");
        this.__selectedPeriod = new ObservedPropertySimplePU(7 // 7天、30天
        , this, "selectedPeriod");
        this.__isLoading = new ObservedPropertySimplePU(true, this, "isLoading");
        this.__chartData = new ObservedPropertyObjectPU([], this, "chartData");
        this.__chartLabels = new ObservedPropertyObjectPU([], this, "chartLabels");
        this.apiClient = ApiClient.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: TrendPage_Params) {
        if (params.stepRecords !== undefined) {
            this.stepRecords = params.stepRecords;
        }
        if (params.totalSteps !== undefined) {
            this.totalSteps = params.totalSteps;
        }
        if (params.avgSteps !== undefined) {
            this.avgSteps = params.avgSteps;
        }
        if (params.maxSteps !== undefined) {
            this.maxSteps = params.maxSteps;
        }
        if (params.selectedPeriod !== undefined) {
            this.selectedPeriod = params.selectedPeriod;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.chartData !== undefined) {
            this.chartData = params.chartData;
        }
        if (params.chartLabels !== undefined) {
            this.chartLabels = params.chartLabels;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
    }
    updateStateVars(params: TrendPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__stepRecords.purgeDependencyOnElmtId(rmElmtId);
        this.__totalSteps.purgeDependencyOnElmtId(rmElmtId);
        this.__avgSteps.purgeDependencyOnElmtId(rmElmtId);
        this.__maxSteps.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedPeriod.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
        this.__chartData.purgeDependencyOnElmtId(rmElmtId);
        this.__chartLabels.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__stepRecords.aboutToBeDeleted();
        this.__totalSteps.aboutToBeDeleted();
        this.__avgSteps.aboutToBeDeleted();
        this.__maxSteps.aboutToBeDeleted();
        this.__selectedPeriod.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        this.__chartData.aboutToBeDeleted();
        this.__chartLabels.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __stepRecords: ObservedPropertyObjectPU<StepRecord[]>;
    get stepRecords() {
        return this.__stepRecords.get();
    }
    set stepRecords(newValue: StepRecord[]) {
        this.__stepRecords.set(newValue);
    }
    private __totalSteps: ObservedPropertySimplePU<number>;
    get totalSteps() {
        return this.__totalSteps.get();
    }
    set totalSteps(newValue: number) {
        this.__totalSteps.set(newValue);
    }
    private __avgSteps: ObservedPropertySimplePU<number>;
    get avgSteps() {
        return this.__avgSteps.get();
    }
    set avgSteps(newValue: number) {
        this.__avgSteps.set(newValue);
    }
    private __maxSteps: ObservedPropertySimplePU<number>;
    get maxSteps() {
        return this.__maxSteps.get();
    }
    set maxSteps(newValue: number) {
        this.__maxSteps.set(newValue);
    }
    private __selectedPeriod: ObservedPropertySimplePU<number>; // 7天、30天
    get selectedPeriod() {
        return this.__selectedPeriod.get();
    }
    set selectedPeriod(newValue: number) {
        this.__selectedPeriod.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private __chartData: ObservedPropertyObjectPU<number[]>;
    get chartData() {
        return this.__chartData.get();
    }
    set chartData(newValue: number[]) {
        this.__chartData.set(newValue);
    }
    private __chartLabels: ObservedPropertyObjectPU<string[]>;
    get chartLabels() {
        return this.__chartLabels.get();
    }
    set chartLabels(newValue: string[]) {
        this.__chartLabels.set(newValue);
    }
    private apiClient;
    aboutToAppear() {
        this.loadStepStatistics();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgColor);
        }, Column);
        // 顶部筛选器
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
        // 统计概览
        this.buildStatisticsOverview.bind(this)();
        // 步数趋势图 - 使用曲线图
        this.buildStepChart.bind(this)();
        // 详细数据列表
        this.buildDataList.bind(this)();
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
            Text.create('步数趋势分析');
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
            Button.createWithLabel('近7天');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.selectedPeriod === 7 ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.selectedPeriod === 7 ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Button.onClick(() => {
                this.selectedPeriod = 7;
                this.loadStepStatistics();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('近30天');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.selectedPeriod === 30 ? AppColors.primaryColor : AppColors.bgColor);
            Button.fontColor(this.selectedPeriod === 30 ? Color.White : AppColors.textColor);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
            Button.onClick(() => {
                this.selectedPeriod = 30;
                this.loadStepStatistics();
            });
        }, Button);
        Button.pop();
        Row.pop();
        Row.pop();
    }
    buildStatisticsOverview(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(AppSpacing.space3Xl);
            Row.backgroundColor(AppColors.bgCard);
            Row.borderRadius(AppBorderRadius.radiusLg);
            Row.shadow(AppShadows.shadowBase);
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.totalSteps.toLocaleString());
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('总步数');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
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
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.avgSteps.toLocaleString());
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.successColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('平均步数');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
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
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.maxSteps.toLocaleString());
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.warningColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('最高步数');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
    }
    buildStepChart(parent = null) {
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
            Text.create('📈 步数趋势曲线图');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.selectedPeriod}天趋势`);
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 使用曲线图组件
            if (this.chartData.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new LineChart(this, {
                                    data: this.chartData,
                                    labels: this.chartLabels,
                                    chartHeight: 250,
                                    lineColor: AppColors.primaryColor,
                                    pointColor: AppColors.warningColor,
                                    gridColor: AppColors.borderColor
                                }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/TrendPage.ets", line: 178, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {
                                        data: this.chartData,
                                        labels: this.chartLabels,
                                        chartHeight: 250,
                                        lineColor: AppColors.primaryColor,
                                        pointColor: AppColors.warningColor,
                                        gridColor: AppColors.borderColor
                                    };
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {
                                    data: this.chartData,
                                    labels: this.chartLabels,
                                    chartHeight: 250,
                                    lineColor: AppColors.primaryColor,
                                    pointColor: AppColors.warningColor,
                                    gridColor: AppColors.borderColor
                                });
                            }
                        }, { name: "LineChart" });
                    }
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.height(250);
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
                        Column.backgroundColor(AppColors.bgCard);
                        Column.borderRadius(AppBorderRadius.radiusLg);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('📊');
                        Text.fontSize(48);
                        Text.margin({ bottom: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无数据');
                        Text.fontSize(AppFonts.fontSizeLg);
                        Text.fontColor(AppColors.textSecondary);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('开始运动记录数据吧！');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.textDisabled);
                        Text.margin({ top: AppSpacing.spaceSm });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    buildDataList(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('📋 详细数据列表');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.titleColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${this.stepRecords.length}条记录`);
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isLoading) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.padding(AppSpacing.space5Xl);
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
            else if (this.stepRecords.length === 0) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.padding(AppSpacing.space5Xl);
                        Column.justifyContent(FlexAlign.Center);
                        Column.alignItems(HorizontalAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('📭');
                        Text.fontSize(48);
                        Text.margin({ bottom: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无步数记录');
                        Text.fontSize(AppFonts.fontSizeLg);
                        Text.fontColor(AppColors.textSecondary);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('快去运动生成数据吧！');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.textDisabled);
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
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
                            this.buildStepRecordItem.bind(this)(record, index);
                        };
                        this.forEachUpdateFunction(elmtId, this.stepRecords, forEachItemGenFunction, undefined, true, false);
                    }, ForEach);
                    ForEach.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    buildStepRecordItem(record: StepRecord, index: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(AppSpacing.spaceLg);
            Row.backgroundColor(index % 2 === 0 ? AppColors.bgColor : Color.Transparent);
            Row.borderRadius(AppBorderRadius.radiusBase);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 日期
            Column.create();
            // 日期
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.formatDate(record.date));
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getWeekDay(record.date));
            Text.fontSize(AppFonts.fontSizeXs);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        // 日期
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 步数
            Column.create();
            // 步数
            Column.alignItems(HorizontalAlign.End);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(record.steps.toLocaleString());
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.primaryColor);
            Text.fontWeight(AppFonts.fontWeightBold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('步');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        // 步数
        Column.pop();
        Row.pop();
    }
    private async loadStepStatistics(): Promise<void> {
        this.isLoading = true;
        try {
            const response = await this.apiClient.getStepStatistics(this.selectedPeriod);
            if (response.code === 1) {
                this.stepRecords = response.data.records;
                this.totalSteps = response.data.totalSteps;
                this.avgSteps = response.data.avgSteps;
                this.maxSteps = response.data.maxSteps;
                // 准备图表数据
                this.prepareChartData();
            }
            else {
                // 模拟数据
                await this.generateMockData();
            }
        }
        catch (error) {
            console.error('Failed to load step statistics:', error);
            // 模拟数据
            await this.generateMockData();
        }
        finally {
            this.isLoading = false;
        }
    }
    private async generateMockData(): Promise<void> {
        // 生成模拟数据
        const mockRecords: StepRecord[] = [];
        let total = 0;
        let max = 0;
        for (let i = this.selectedPeriod - 1; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateString = date.toISOString().split('T')[0];
            const steps = Math.floor(Math.random() * 15000) + 3000;
            mockRecords.push({
                id: i + 1,
                date: dateString,
                steps: steps,
                timestamp: date.toISOString()
            });
            total += steps;
            if (steps > max)
                max = steps;
        }
        this.stepRecords = mockRecords;
        this.totalSteps = total;
        this.avgSteps = Math.round(total / this.selectedPeriod);
        this.maxSteps = max;
        // 准备图表数据
        this.prepareChartData();
    }
    private prepareChartData(): void {
        if (this.stepRecords.length === 0) {
            this.chartData = [];
            this.chartLabels = [];
            return;
        }
        // 按日期排序
        const sortedRecords = [...this.stepRecords].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        // 准备图表数据
        this.chartData = sortedRecords.map(record => record.steps);
        this.chartLabels = sortedRecords.map(record => {
            const date = new Date(record.date);
            return `${date.getMonth() + 1}/${date.getDate()}`;
        });
    }
    private formatDate(dateStr: string): string {
        const date = new Date(dateStr);
        return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
    }
    private getWeekDay(dateStr: string): string {
        const date = new Date(dateStr);
        const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
        return weekDays[date.getDay()];
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "TrendPage";
    }
}
registerNamedRoute(() => new TrendPage(undefined, {}), "", { bundleName: "com.hssp.app", moduleName: "entry", pagePath: "pages/TrendPage", pageFullPath: "entry/src/main/ets/pages/TrendPage", integratedHsp: "false", moduleType: "followWithHap" });
