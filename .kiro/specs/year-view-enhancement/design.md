# 设计文档

## 概述

本设计文档详细描述了LinearLifeCalendar线性日历功能完善的技术实现方案。线性日历即为年视图的核心概念，以线性方式展示整年时间线。主要目标是确保线性日历能够正确显示当年度所有日期，并在左右两侧添加月份标签，提供更好的用户体验和视觉导航。

## 架构

### 现有架构分析

当前的YearView.swift实现了基本的线性日历功能，但存在以下问题：
- 使用固定的37列布局可能导致某些日期显示不全
- 月份标签已存在但可能需要优化对齐
- 日期计算逻辑需要确保覆盖全年所有日期

### 改进架构设计

线性日历架构将以线性时间轴的方式展示全年日期：

```
LinearCalendarView (线性日历视图)
├── YearHeader (年份标题)
├── ScrollView
│   └── LazyVStack
│       ├── HeaderRow (星期标题行)
│       ├── MonthRow × 12 (月份行 - 线性排列)
│       │   ├── LeftMonthLabel (左侧月份标签)
│       │   ├── LinearDayGrid (线性日期网格)
│       │   │   └── DayCell × N (日期单元格)
│       │   └── RightMonthLabel (右侧月份标签)
│       └── HeaderRow (底部星期标题行)
```

## 组件和接口

### 1. LinearCalendarView 主组件

**职责**: 协调整个线性日历的显示和交互，以线性时间轴方式展示全年

**关键属性**:
- `currentDate: Date` - 当前显示的年份日期
- `events: [CalendarEvent]` - 事件数据
- `columnsCount: Int` - 列数（建议调整为42以确保完整显示）

**关键方法**:
- `linearMonthRow(for monthDate: Date) -> some View` - 生成线性月份行
- `linearDayCell(for date: Date, dayNumber: Int, isWeekend: Bool) -> some View` - 生成线性日期单元格
- `calculateOptimalColumns() -> Int` - 计算最优列数

### 2. LinearMonthRowCalculator 计算器

**职责**: 处理线性月份行的日期计算和布局

```swift
struct LinearMonthRowCalculator {
    let monthDate: Date
    let columnsCount: Int
    
    func calculateLinearDayPositions() -> [LinearDayPosition]
    func getValidDaysCount() -> Int
    func getMonthStartOffset() -> Int
}

struct LinearDayPosition {
    let date: Date
    let columnIndex: Int
    let isValid: Bool
    let dayNumber: Int
    let linearPosition: Int // 在年度时间轴中的位置
}
```

### 3. MonthLabel 组件

**职责**: 显示月份标签

```swift
struct MonthLabel: View {
    let monthDate: Date
    let alignment: HorizontalAlignment
    let height: CGFloat
    
    var body: some View
}
```

## 数据模型

### 日期计算模型

```swift
extension Date {
    // 新增方法
    func getAllDaysInYear() -> [Date]
    func getWeekdayOffset(for firstDayOfMonth: Date) -> Int
    func getDaysCountInMonth() -> Int
    func isValidDayInMonth(_ dayNumber: Int) -> Bool
}
```

### 布局配置模型

```swift
struct LinearCalendarConfiguration {
    let cellWidth: CGFloat = 56
    let cellHeight: CGFloat = 128
    let monthLabelWidth: CGFloat = 96
    let columnsCount: Int = 42 // 6周 × 7天
    let spacing: CGFloat = 0
    let linearTimelineHeight: CGFloat = 1536 // 12个月 × 128高度
}
```

## 正确性属性

*属性是应该在系统所有有效执行中保持为真的特征或行为——本质上是关于系统应该做什么的正式陈述。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

现在我需要分析验收标准的可测试性：

基于预工作分析，我将把可测试的验收标准转换为正确性属性：

### 属性 1: 完整线性日历显示
*对于任何* 年份，线性日历应该显示该年的所有有效日期，每个日期都应该根据其星期几正确放置在网格中的对应位置
**验证: 需求 1.1, 1.2, 1.4**

### 属性 2: 线性月份边界对齐
*对于任何* 月份，该月的第一天应该对齐到正确的星期几列，最后一天应该正确结束，保持线性时间轴的连续性
**验证: 需求 1.3**

### 属性 3: 线性月份标签完整性
*对于任何* 线性日历中的月份行，左侧和右侧都应该显示对应的中文月份标签
**验证: 需求 2.1, 2.2, 2.3**

### 属性 4: 线性月份行数量
*对于任何* 线性日历，应该恰好显示12行，每行对应一个月份，形成完整的年度时间轴
**验证: 需求 2.4**

### 属性 5: 线性日期单元格一致性
*对于任何* 线性日历中的日期单元格，所有单元格应该具有相同的尺寸和一致的间距，保持时间轴的视觉连续性
**验证: 需求 3.1, 4.5**

### 属性 6: 线性周末日期区分
*对于任何* 线性日历中的周末日期（周六和周日），应该使用不同的背景色与工作日进行视觉区分
**验证: 需求 3.3**

## 错误处理

### 日期计算错误
- **无效日期输入**: 当传入无效日期时，使用当前日期作为默认值
- **闰年处理**: 正确处理闰年的2月29日
- **年份边界**: 处理年份切换时的边界情况

### 布局错误
- **屏幕尺寸适配**: 当屏幕尺寸不足时，调整单元格大小或启用水平滚动
- **内容溢出**: 当事件内容过多时，限制显示数量并提供展开选项

### 性能错误
- **大量事件**: 实现事件的懒加载和虚拟化
- **内存管理**: 及时释放不再需要的视图和数据

## 测试策略

### 双重测试方法
本项目将采用单元测试和属性测试相结合的方法：

**单元测试**:
- 验证特定示例和边缘情况
- 测试今天日期的高亮显示
- 测试星期标题的正确顺序
- 测试错误条件和边界情况

**属性测试**:
- 验证跨所有输入的通用属性
- 使用随机生成的年份和月份进行测试
- 每个属性测试运行最少100次迭代
- 通过随机化实现全面的输入覆盖

**属性测试配置**:
- 使用Swift的XCTest框架结合自定义属性测试工具
- 最少100次迭代以确保充分的随机化覆盖
- 每个属性测试必须引用其设计文档属性
- 标签格式: **Feature: year-view-enhancement, Property {number}: {property_text}**

**测试平衡**:
- 单元测试专注于具体示例、集成点和边缘情况
- 属性测试处理大量输入的覆盖
- 两种测试类型互补，共同提供全面覆盖

### 测试数据生成
- **随机年份生成器**: 生成1900-2100年范围内的随机年份
- **随机月份生成器**: 生成1-12月的随机月份
- **随机日期生成器**: 生成有效的随机日期
- **边缘情况生成器**: 专门生成闰年、月份边界等特殊情况

### 测试验证点
- 日期数量验证
- 位置对齐验证
- 标签内容验证
- 布局一致性验证
- 视觉区分验证