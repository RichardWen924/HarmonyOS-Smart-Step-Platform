if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface LineChart_Params {
    data?: number[];
    labels?: string[];
    chartHeight?: number;
    lineColor?: string;
    pointColor?: string;
    gridColor?: string;
    settings?: RenderingContextSettings;
    context?: CanvasRenderingContext2D;
}
import { AppColors, AppSpacing } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
export class LineChart extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__data = new SynchedPropertyObjectOneWayPU(params.data, this, "data");
        this.__labels = new SynchedPropertyObjectOneWayPU(params.labels, this, "labels");
        this.__chartHeight = new SynchedPropertySimpleOneWayPU(params.chartHeight, this, "chartHeight");
        this.__lineColor = new SynchedPropertySimpleOneWayPU(params.lineColor, this, "lineColor");
        this.__pointColor = new SynchedPropertySimpleOneWayPU(params.pointColor, this, "pointColor");
        this.__gridColor = new SynchedPropertySimpleOneWayPU(params.gridColor, this, "gridColor");
        this.settings = new RenderingContextSettings(true);
        this.context = new CanvasRenderingContext2D(this.settings);
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: LineChart_Params) {
        if (params.data === undefined) {
            this.__data.set([]);
        }
        if (params.labels === undefined) {
            this.__labels.set([]);
        }
        if (params.chartHeight === undefined) {
            this.__chartHeight.set(200);
        }
        if (params.lineColor === undefined) {
            this.__lineColor.set(AppColors.primaryColor);
        }
        if (params.pointColor === undefined) {
            this.__pointColor.set(AppColors.warningColor);
        }
        if (params.gridColor === undefined) {
            this.__gridColor.set(AppColors.borderColor);
        }
        if (params.settings !== undefined) {
            this.settings = params.settings;
        }
        if (params.context !== undefined) {
            this.context = params.context;
        }
    }
    updateStateVars(params: LineChart_Params) {
        this.__data.reset(params.data);
        this.__labels.reset(params.labels);
        this.__chartHeight.reset(params.chartHeight);
        this.__lineColor.reset(params.lineColor);
        this.__pointColor.reset(params.pointColor);
        this.__gridColor.reset(params.gridColor);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__data.purgeDependencyOnElmtId(rmElmtId);
        this.__labels.purgeDependencyOnElmtId(rmElmtId);
        this.__chartHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__lineColor.purgeDependencyOnElmtId(rmElmtId);
        this.__pointColor.purgeDependencyOnElmtId(rmElmtId);
        this.__gridColor.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__data.aboutToBeDeleted();
        this.__labels.aboutToBeDeleted();
        this.__chartHeight.aboutToBeDeleted();
        this.__lineColor.aboutToBeDeleted();
        this.__pointColor.aboutToBeDeleted();
        this.__gridColor.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __data: SynchedPropertySimpleOneWayPU<number[]>;
    get data() {
        return this.__data.get();
    }
    set data(newValue: number[]) {
        this.__data.set(newValue);
    }
    private __labels: SynchedPropertySimpleOneWayPU<string[]>;
    get labels() {
        return this.__labels.get();
    }
    set labels(newValue: string[]) {
        this.__labels.set(newValue);
    }
    private __chartHeight: SynchedPropertySimpleOneWayPU<number>;
    get chartHeight() {
        return this.__chartHeight.get();
    }
    set chartHeight(newValue: number) {
        this.__chartHeight.set(newValue);
    }
    private __lineColor: SynchedPropertySimpleOneWayPU<string>;
    get lineColor() {
        return this.__lineColor.get();
    }
    set lineColor(newValue: string) {
        this.__lineColor.set(newValue);
    }
    private __pointColor: SynchedPropertySimpleOneWayPU<string>;
    get pointColor() {
        return this.__pointColor.get();
    }
    set pointColor(newValue: string) {
        this.__pointColor.set(newValue);
    }
    private __gridColor: SynchedPropertySimpleOneWayPU<string>;
    get gridColor() {
        return this.__gridColor.get();
    }
    set gridColor(newValue: string) {
        this.__gridColor.set(newValue);
    }
    private settings: RenderingContextSettings;
    private context: CanvasRenderingContext2D;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Canvas.create(this.context);
            Canvas.width('100%');
            Canvas.height(this.chartHeight);
            Canvas.backgroundColor(Color.Transparent);
            Canvas.onReady(() => {
                this.drawChart();
            });
        }, Canvas);
        Canvas.pop();
        Column.pop();
    }
    private drawChart(): void {
        if (this.data.length === 0)
            return;
        const width = this.context.width;
        const height = this.chartHeight;
        const padding = 40;
        const chartWidth = width - 2 * padding;
        const chartHeight = height - 2 * padding;
        // 清空画布
        this.context.clearRect(0, 0, width, height);
        // 计算数据范围
        const min = Math.min(...this.data);
        const max = Math.max(...this.data);
        const range = max - min || 1; // 防止除零
        // 映射函数：将数据值转为Y坐标
        const valueToY = (value: number): number => {
            return height - padding - ((value - min) / range) * chartHeight;
        };
        // 绘制网格线
        this.context.strokeStyle = this.gridColor;
        this.context.lineWidth = 1;
        this.context.setLineDash([2, 2]);
        // 水平网格线
        for (let i = 0; i <= 4; i++) {
            const y = padding + (chartHeight / 4) * i;
            this.context.beginPath();
            this.context.moveTo(padding, y);
            this.context.lineTo(width - padding, y);
            this.context.stroke();
        }
        this.context.setLineDash([]);
        // 绘制Y轴标签
        this.context.font = '12px sans-serif';
        this.context.fillStyle = AppColors.textSecondary;
        this.context.textAlign = 'right';
        for (let i = 0; i <= 4; i++) {
            const value = min + (range / 4) * i;
            const y = padding + (chartHeight / 4) * (4 - i);
            this.context.fillText(Math.round(value).toString(), padding - 8, y + 4);
        }
        // 绘制X轴标签
        this.context.textAlign = 'center';
        const stepX = chartWidth / (this.labels.length - 1 || 1);
        for (let i = 0; i < this.labels.length; i++) {
            const x = padding + i * stepX;
            this.context.fillText(this.labels[i], x, height - padding + 20);
        }
        // 绘制曲线
        if (this.data.length > 1) {
            const path = new Path2D();
            const stepX = chartWidth / (this.data.length - 1);
            for (let i = 0; i < this.data.length; i++) {
                const x = padding + i * stepX;
                const y = valueToY(this.data[i]);
                if (i === 0) {
                    path.moveTo(x, y);
                }
                else {
                    // 使用贝塞尔曲线实现平滑效果
                    const prevX = padding + (i - 1) * stepX;
                    const prevY = valueToY(this.data[i - 1]);
                    const cp1x = prevX + stepX * 0.3;
                    const cp1y = prevY;
                    const cp2x = x - stepX * 0.3;
                    const cp2y = y;
                    path.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
                }
                // 绘制数据点
                this.context.beginPath();
                this.context.arc(x, y, 4, 0, 2 * Math.PI);
                this.context.fillStyle = this.pointColor;
                this.context.fill();
                // 数据点标签
                this.context.fillStyle = AppColors.textColor;
                this.context.textAlign = 'center';
                this.context.fillText(this.data[i].toString(), x, y - 10);
            }
            // 绘制曲线
            this.context.strokeStyle = this.lineColor;
            this.context.lineWidth = 3;
            this.context.stroke(path);
        }
        // 绘制坐标轴
        this.context.strokeStyle = AppColors.textSecondary;
        this.context.lineWidth = 2;
        // Y轴
        this.context.beginPath();
        this.context.moveTo(padding, padding);
        this.context.lineTo(padding, height - padding);
        this.context.stroke();
        // X轴
        this.context.beginPath();
        this.context.moveTo(padding, height - padding);
        this.context.lineTo(width - padding, height - padding);
        this.context.stroke();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
