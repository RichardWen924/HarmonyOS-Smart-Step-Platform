import { AppColors, AppFonts, AppSpacing } from '../config/DesignSystem'

// 曲线图组件
@Component
export struct LineChart {
  @Prop data: number[] = []
  @Prop labels: string[] = []
  @Prop chartHeight: number = 200
  @Prop lineColor: string = AppColors.primaryColor
  @Prop pointColor: string = AppColors.warningColor
  @Prop gridColor: string = AppColors.borderColor
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height(this.chartHeight)
        .backgroundColor(Color.Transparent)
        .onReady(() => {
          this.drawChart()
        })
    }
    .width('100%')
    .margin({ top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
  }

  private drawChart(): void {
    if (this.data.length === 0) return

    const width = this.context.width
    const height = this.chartHeight
    const padding = 40
    const chartWidth = width - 2 * padding
    const chartHeight = height - 2 * padding

    // 清空画布
    this.context.clearRect(0, 0, width, height)

    // 计算数据范围
    const min = Math.min(...this.data)
    const max = Math.max(...this.data)
    const range = max - min || 1 // 防止除零

    // 映射函数：将数据值转为Y坐标
    const valueToY = (value: number): number => {
      return height - padding - ((value - min) / range) * chartHeight
    }

    // 绘制网格线
    this.context.strokeStyle = this.gridColor
    this.context.lineWidth = 1
    this.context.setLineDash([2, 2])

    // 水平网格线
    for (let i = 0; i <= 4; i++) {
      const y = padding + (chartHeight / 4) * i
      this.context.beginPath()
      this.context.moveTo(padding, y)
      this.context.lineTo(width - padding, y)
      this.context.stroke()
    }

    this.context.setLineDash([])

    // 绘制Y轴标签
    this.context.font = '12px sans-serif'
    this.context.fillStyle = AppColors.textSecondary
    this.context.textAlign = 'right'
    
    for (let i = 0; i <= 4; i++) {
      const value = min + (range / 4) * i
      const y = padding + (chartHeight / 4) * (4 - i)
      this.context.fillText(Math.round(value).toString(), padding - 8, y + 4)
    }

    // 绘制X轴标签
    this.context.textAlign = 'center'
    const stepX = chartWidth / (this.labels.length - 1 || 1)
    
    for (let i = 0; i < this.labels.length; i++) {
      const x = padding + i * stepX
      this.context.fillText(this.labels[i], x, height - padding + 20)
    }

    // 绘制曲线
    if (this.data.length > 1) {
      const path = new Path2D()
      const stepX = chartWidth / (this.data.length - 1)
      
      for (let i = 0; i < this.data.length; i++) {
        const x = padding + i * stepX
        const y = valueToY(this.data[i])
        
        if (i === 0) {
          path.moveTo(x, y)
        } else {
          // 使用贝塞尔曲线实现平滑效果
          const prevX = padding + (i - 1) * stepX
          const prevY = valueToY(this.data[i - 1])
          const cp1x = prevX + stepX * 0.3
          const cp1y = prevY
          const cp2x = x - stepX * 0.3
          const cp2y = y
          
          path.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)
        }

        // 绘制数据点
        this.context.beginPath()
        this.context.arc(x, y, 4, 0, 2 * Math.PI)
        this.context.fillStyle = this.pointColor
        this.context.fill()
        
        // 数据点标签
        this.context.fillStyle = AppColors.textColor
        this.context.textAlign = 'center'
        this.context.fillText(this.data[i].toString(), x, y - 10)
      }

      // 绘制曲线
      this.context.strokeStyle = this.lineColor
      this.context.lineWidth = 3
      this.context.stroke(path)
    }

    // 绘制坐标轴
    this.context.strokeStyle = AppColors.textSecondary
    this.context.lineWidth = 2
    
    // Y轴
    this.context.beginPath()
    this.context.moveTo(padding, padding)
    this.context.lineTo(padding, height - padding)
    this.context.stroke()
    
    // X轴
    this.context.beginPath()
    this.context.moveTo(padding, height - padding)
    this.context.lineTo(width - padding, height - padding)
    this.context.stroke()
  }
}