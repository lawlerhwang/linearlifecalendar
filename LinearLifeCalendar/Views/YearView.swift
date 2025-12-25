import SwiftUI

struct YearView: View {
    let currentDate: Date
    let events: [CalendarEvent]
    let onDateClick: (Date) -> Void
    let onCreateEvent: (Date, Date?) -> Void
    let onEventClick: (CalendarEvent) -> Void
    
    @State private var isDragging = false
    @State private var selectionStart: Date?
    @State private var selectionEnd: Date?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                yearHeader
                calendarGrid(availableWidth: geometry.size.width)
            }
            .background(Color(NSColor.windowBackgroundColor))
            .onTapGesture { _ in
                clearSelection()
            }
        }
    }
    
    // 日历网格
    private func calendarGrid(availableWidth: CGFloat) -> some View {
        let monthLabelWidth: CGFloat = 80
        let totalDayColumns: CGFloat = 31
        let availableForDays = availableWidth - (monthLabelWidth * 2) - 48 // 减去左右月份标签和padding
        let dayColumnWidth = max(12, availableForDays / totalDayColumns) // 最小12像素宽度
        
        return ScrollView([.horizontal, .vertical]) {
            LazyVStack(spacing: 0) {
                headerRow(dayColumnWidth: dayColumnWidth, monthLabelWidth: monthLabelWidth)
                monthRows(dayColumnWidth: dayColumnWidth, monthLabelWidth: monthLabelWidth)
                headerRow(dayColumnWidth: dayColumnWidth, monthLabelWidth: monthLabelWidth)
            }
            .padding(.bottom, 32)
        }
    }
    
    // 月份行集合
    private func monthRows(dayColumnWidth: CGFloat, monthLabelWidth: CGFloat) -> some View {
        ForEach(currentDate.monthsInYear(), id: \.self) { monthDate in
            monthRow(for: monthDate, dayColumnWidth: dayColumnWidth, monthLabelWidth: monthLabelWidth)
        }
    }
    
    // 年份标题
    private var yearHeader: some View {
        HStack {
            yearTitleSection
            Spacer()
            yearSubtitleSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    // 年份标题部分
    private var yearTitleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(currentDate.year)年")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.primary)
            
            Text("Linear Overview")
                .font(.system(size: 18, design: .serif))
                .italic()
                .foregroundColor(.secondary)
        }
    }
    
    // 年份副标题部分
    private var yearSubtitleSection: some View {
        VStack(alignment: .trailing) {
            Text("Life is bigger than a week.")
                .font(.system(size: 11, weight: .medium))
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundColor(.secondary)
        }
    }
    
    // 表头行 - 适应线性日历布局
    private func headerRow(dayColumnWidth: CGFloat, monthLabelWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            // 月份标签占位
            headerPlaceholder(width: monthLabelWidth)
            
            // 星期标签 - 显示31天的星期循环
            ForEach(0..<31, id: \.self) { index in
                weekdayHeader(for: index, width: dayColumnWidth)
            }
            
            // 右侧月份标签占位
            headerPlaceholder(width: monthLabelWidth)
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    // 表头占位符
    private func headerPlaceholder(width: CGFloat) -> some View {
        Rectangle()
            .fill(Color(NSColor.windowBackgroundColor))
            .frame(width: width, height: 30) // 使用动态宽度
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .trailing
            )
    }
    
    // 星期标题
    private func weekdayHeader(for index: Int, width: CGFloat) -> some View {
        let dayName = getChineseDayName(for: index)
        let isWeekend = isWeekendColumn(columnIndex: index)
        
        return Rectangle()
            .fill(isWeekend ? Color.gray.opacity(0.15) : Color(NSColor.windowBackgroundColor))
            .frame(width: width, height: 30) // 使用动态宽度
            .overlay(
                Text(dayName)
                    .font(.system(size: min(8, width * 0.4), weight: .medium)) // 根据宽度调整字体大小
                    .foregroundColor(isWeekend ? .secondary : .primary)
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
    }
    
    // 月份行 - 真正对齐的线性日历实现
    private func monthRow(for monthDate: Date, dayColumnWidth: CGFloat, monthLabelWidth: CGFloat) -> some View {
        let calendar = Calendar.current
        let monthStartDate = monthDate.startOfMonth
        let monthName = validateChineseMonthName(for: monthDate)
        
        // 计算该月的天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
        
        // 计算该月1号是星期几 (1=周日, 2=周一, ..., 7=周六)
        let firstDayWeekday = calendar.component(.weekday, from: monthStartDate)
        
        // 修正：2025年1月1日是周三，需要调整weekday计算
        // 将周日=1转换为周日=0, 周一=1, ..., 周六=6
        let adjustedWeekday = (firstDayWeekday - 1) % 7
        
        // 计算需要的前置空白天数
        let leadingEmptyDays = adjustedWeekday
        
        // 固定显示31列（最大月份天数），确保所有月份对齐
        let totalColumns = 31
        
        return HStack(spacing: 0) {
            // 左侧月份标签
            monthLabel(monthName: monthName, alignment: .trailing, width: monthLabelWidth)
            
            // 日期网格 - 固定31列确保对齐
            ForEach(0..<totalColumns, id: \.self) { index in
                if index < leadingEmptyDays {
                    // 前置空白
                    emptyAlignedCell(columnIndex: index, width: dayColumnWidth)
                } else if index < leadingEmptyDays + daysInMonth {
                    // 实际日期
                    let dayNumber = index - leadingEmptyDays + 1
                    if let dayDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: monthStartDate) {
                        alignedDayCell(for: dayDate, dayNumber: dayNumber, columnIndex: index, width: dayColumnWidth)
                    } else {
                        emptyAlignedCell(columnIndex: index, width: dayColumnWidth)
                    }
                } else {
                    // 后置空白
                    emptyAlignedCell(columnIndex: index, width: dayColumnWidth)
                }
            }
            
            // 右侧月份标签
            monthLabel(monthName: monthName, alignment: .leading, width: monthLabelWidth)
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    // 改进的日期计算方法 - 确保月份边界对齐准确性
    private func calculateDateForPosition(monthStartDate: Date, dayNumber: Int) -> Date? {
        let calendar = Calendar.current
        
        // 验证日期数字的有效性
        guard dayNumber > 0 else { return nil }
        
        // 计算目标日期
        let targetDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: monthStartDate)
        
        // 验证计算出的日期确实属于同一个月
        if let targetDate = targetDate {
            let targetMonth = calendar.component(.month, from: targetDate)
            let originalMonth = calendar.component(.month, from: monthStartDate)
            let targetYear = calendar.component(.year, from: targetDate)
            let originalYear = calendar.component(.year, from: monthStartDate)
            
            // 确保年份和月份匹配
            if targetMonth == originalMonth && targetYear == originalYear {
                return targetDate
            }
        }
        
        return nil
    }
    
    // 空单元格类型枚举
    private enum EmptyCellReason {
        case beforeMonth    // 月份开始前的空单元格
        case afterMonth     // 月份结束后的空单元格
        case invalidDate    // 无效日期的空单元格
    }
    
    // 优化的空单元格 - 改进空白单元格显示逻辑
    private func optimizedEmptyCell(isWeekend: Bool, reason: EmptyCellReason) -> some View {
        let baseColor = isWeekend ? Color.gray.opacity(0.1) : Color.gray.opacity(0.15)
        let patternOpacity = getPatternOpacity(for: reason)
        
        return Rectangle()
            .fill(baseColor)
            .frame(width: 3, height: 128) // 非常窄的列以显示全年
            .overlay(emptyCellPattern(reason: reason, opacity: patternOpacity))
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
    }
    
    // 获取图案透明度
    private func getPatternOpacity(for reason: EmptyCellReason) -> Double {
        switch reason {
        case .beforeMonth: return 0.2
        case .afterMonth: return 0.25
        case .invalidDate: return 0.4
        }
    }
    
    // 空单元格图案
    private func emptyCellPattern(reason: EmptyCellReason, opacity: Double) -> some View {
        ZStack {
            Path { path in
                let spacing: CGFloat = reason == .invalidDate ? 8 : 12
                for i in stride(from: -128, through: 56, by: spacing) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i + 128, y: 128))
                }
            }
            .stroke(Color.gray.opacity(opacity), lineWidth: 1)
        }
    }
    
    // 日期单元格 - 简化表达式
    private func dayCell(for date: Date, dayNumber: Int, isWeekend: Bool) -> some View {
        let dayEvents = events.filter { $0.occursOn(date: date) }
            .sorted { $0.startDate < $1.startDate }
        let isToday = date.isToday
        let isSelected = isDateSelected(date)
        
        return Rectangle()
            .fill(backgroundColor(for: date, isWeekend: isWeekend, isSelected: isSelected))
            .frame(width: 3, height: 128) // 非常窄的列以显示全年
            .overlay(
                dayContent(
                    dayNumber: dayNumber,
                    isToday: isToday,
                    dayEvents: dayEvents,
                    date: date
                )
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                onCreateEvent(date, nil)
            }
            .gesture(dayDragGesture(for: date))
    }
    
    // 日期内容 - 简化版本适应窄列
    private func dayContent(
        dayNumber: Int,
        isToday: Bool,
        dayEvents: [CalendarEvent],
        date: Date
    ) -> some View {
        VStack(spacing: 1) {
            // 简化的日期显示 - 只显示颜色指示
            Rectangle()
                .fill(isToday ? Color.blue : (dayEvents.isEmpty ? Color.clear : Color.red))
                .frame(height: 2)
            
            // 事件指示器
            if !dayEvents.isEmpty {
                Rectangle()
                    .fill(dayEvents.first?.color ?? Color.gray)
                    .frame(height: 4)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDateClick(date)
        }
    }
    
    // 日期拖拽手势 - 分离复杂的手势逻辑
    private func dayDragGesture(for date: Date) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    selectionStart = date
                }
                // 这里可以添加拖拽选择逻辑
            }
            .onEnded { _ in
                if let start = selectionStart {
                    if isDragging {
                        onCreateEvent(start, selectionEnd)
                    }
                }
                clearSelection()
            }
    }
    
    // 空单元格 - 保持向后兼容性
    private func emptyCell(isWeekend: Bool) -> some View {
        optimizedEmptyCell(isWeekend: isWeekend, reason: .afterMonth)
    }
    
    // 事件条
    private func eventBar(for event: CalendarEvent, date: Date) -> some View {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        let continuesPrev = event.startDate < dayStart
        let continuesNext = event.endDate > dayEnd
        let isFirstDayOfMonth = date.day == 1
        let showTitle = !continuesPrev || isFirstDayOfMonth
        
        return Button(action: {
            onEventClick(event)
        }) {
            eventBarContent(
                event: event,
                showTitle: showTitle,
                continuesPrev: continuesPrev,
                continuesNext: continuesNext
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 事件条内容
    private func eventBarContent(
        event: CalendarEvent,
        showTitle: Bool,
        continuesPrev: Bool,
        continuesNext: Bool
    ) -> some View {
        Rectangle()
            .fill(event.color)
            .frame(height: 14)
            .overlay(
                eventBarTitle(event: event, showTitle: showTitle)
            )
            .cornerRadius(continuesPrev && continuesNext ? 0 : 3)
    }
    
    // 事件条标题
    private func eventBarTitle(event: CalendarEvent, showTitle: Bool) -> some View {
        HStack {
            if showTitle {
                Text(event.title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 3)
            }
            Spacer(minLength: 0)
        }
    }
    
    // 背景颜色
    private func backgroundColor(for date: Date, isWeekend: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return Color.blue.opacity(0.1)
        } else if date.isToday {
            return Color.blue.opacity(0.05)
        } else if isWeekend {
            return Color.gray.opacity(0.05)
        } else {
            return Color(NSColor.windowBackgroundColor)
        }
    }
    
    // 检查日期是否被选中
    private func isDateSelected(_ date: Date) -> Bool {
        guard isDragging, let start = selectionStart else { return false }
        
        if let end = selectionEnd {
            let startDate = min(start, end)
            let endDate = max(start, end)
            return date >= startDate && date <= endDate
        } else {
            return Calendar.current.isDate(date, inSameDayAs: start)
        }
    }
    
    // 月份标签 - 提取为独立方法以简化表达式
    private func monthLabel(monthName: String, alignment: Alignment, width: CGFloat) -> some View {
        Rectangle()
            .fill(Color(NSColor.windowBackgroundColor))
            .frame(width: width, height: 100) // 使用动态宽度
            .overlay(
                VStack {
                    Spacer()
                    Text(monthName)
                        .font(.system(size: min(14, width * 0.18), weight: .bold, design: .serif)) // 根据宽度调整字体大小
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer()
                }
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: alignment
            )
    }
    
    // 对齐的日期单元格 - 确保星期几对齐
    private func alignedDayCell(for date: Date, dayNumber: Int, columnIndex: Int, width: CGFloat) -> some View {
        let dayEvents = events.filter { $0.occursOn(date: date) }
        let isToday = date.isToday
        let isWeekend = isWeekendColumn(columnIndex: columnIndex)
        
        return Rectangle()
            .fill(getAlignedDayColor(isToday: isToday, isWeekend: isWeekend, hasEvents: !dayEvents.isEmpty))
            .frame(width: width, height: 100) // 使用动态宽度
            .overlay(
                VStack(spacing: 2) {
                    // 显示日期数字
                    Text("\(dayNumber)")
                        .font(.system(size: min(8, width * 0.4), weight: .medium)) // 根据宽度调整字体大小
                        .foregroundColor(isToday ? .white : .primary)
                        .minimumScaleFactor(0.5)
                    
                    // 事件指示器
                    if !dayEvents.isEmpty {
                        Circle()
                            .fill(dayEvents.first?.color ?? Color.red)
                            .frame(width: min(4, width * 0.2), height: min(4, width * 0.2)) // 根据宽度调整指示器大小
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
            )
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .onTapGesture {
                onDateClick(date)
            }
            .onTapGesture(count: 2) {
                onCreateEvent(date, nil)
            }
    }
    
    // 对齐的空单元格
    private func emptyAlignedCell(columnIndex: Int, width: CGFloat) -> some View {
        let isWeekend = isWeekendColumn(columnIndex: columnIndex)
        
        return Rectangle()
            .fill(isWeekend ? Color.gray.opacity(0.15) : Color.gray.opacity(0.05))
            .frame(width: width, height: 100) // 使用动态宽度
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
    
    // 判断是否是周末列 (周六和周日)
    private func isWeekendColumn(columnIndex: Int) -> Bool {
        let weekday = columnIndex % 7
        return weekday == 5 || weekday == 6 // 周六=5, 周日=6 (因为周一=0)
    }
    
    // 获取对齐日期颜色
    private func getAlignedDayColor(isToday: Bool, isWeekend: Bool, hasEvents: Bool) -> Color {
        if isToday {
            return Color.blue
        } else if hasEvents {
            return Color.red.opacity(0.7)
        } else if isWeekend {
            return Color.gray.opacity(0.15) // 周末背景色
        } else {
            return Color(NSColor.windowBackgroundColor)
        }
    }
    
    // 空的线性单元格
    private func emptyLinearCell() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.05))
            .frame(width: 20, height: 100)
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
    }
    
    // 获取线性日期颜色
    private func getLinearDayColor(isToday: Bool, isWeekend: Bool, hasEvents: Bool) -> Color {
        if isToday {
            return Color.blue
        } else if hasEvents {
            return Color.red.opacity(0.7)
        } else if isWeekend {
            return Color.gray.opacity(0.2)
        } else {
            return Color(NSColor.windowBackgroundColor)
        }
    }
    
    // 中文星期名称 - 修正为周一开始
    private func getChineseDayName(for index: Int) -> String {
        let days = ["一", "二", "三", "四", "五", "六", "日"] // 周一到周日
        return days[index % 7]
    }
    
    // 验证中文月份名称的正确性 - 简化版本
    private func validateChineseMonthName(for monthDate: Date) -> String {
        // 直接使用Date扩展的方法，避免复杂的验证逻辑
        return monthDate.chineseMonthName
    }
    
    // 清除选择状态
    private func clearSelection() {
        isDragging = false
        selectionStart = nil
        selectionEnd = nil
    }
}

#Preview {
    YearView(
        currentDate: Date(),
        events: [],
        onDateClick: { _ in },
        onCreateEvent: { _, _ in },
        onEventClick: { _ in }
    )
    .frame(width: 1200, height: 800)
}
