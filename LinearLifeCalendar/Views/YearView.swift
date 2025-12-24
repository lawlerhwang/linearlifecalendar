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
    
    private let chineseDays = ["日", "一", "二", "三", "四", "五", "六"]
    private let columnsCount = 37
    
    var body: some View {
        VStack(spacing: 0) {
            // 年份标题
            yearHeader
            
            // 日历网格
            ScrollView {
                LazyVStack(spacing: 0) {
                    // 表头
                    headerRow
                    
                    // 月份行
                    ForEach(currentDate.monthsInYear(), id: \.self) { monthDate in
                        monthRow(for: monthDate)
                    }
                    
                    // 底部表头
                    headerRow
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onTapGesture { _ in
            // 清除选择状态
            clearSelection()
        }
    }
    
    // 年份标题
    private var yearHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(currentDate.year)年")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Text("Linear Overview")
                    .font(.system(size: 18, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Life is bigger than a week.")
                    .font(.system(size: 11, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundColor(.secondary)
            }
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
    
    // 表头行
    private var headerRow: some View {
        HStack(spacing: 0) {
            // 月份标签占位
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(width: 96, height: 40)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .trailing
                )
            
            // 星期标签
            ForEach(0..<columnsCount, id: \.self) { index in
                let dayName = chineseDays[index % 7]
                let isWeekend = (index % 7 == 0 || index % 7 == 6)
                
                Rectangle()
                    .fill(isWeekend ? Color.gray.opacity(0.05) : Color(NSColor.windowBackgroundColor))
                    .frame(width: 56, height: 40) // 匹配日期单元格宽度
                    .overlay(
                        Text(dayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isWeekend ? .secondary : .primary)
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.gray.opacity(0.1)),
                        alignment: .trailing
                    )
            }
            
            // 右侧月份标签占位
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(width: 96, height: 40)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .leading
                )
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    // 月份行
    private func monthRow(for monthDate: Date) -> some View {
        let calendar = Calendar.current
        let monthStartDayIndex = calendar.component(.weekday, from: monthDate.startOfMonth) - 1 // 0=周日, 1=周一...
        let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
        let monthName = monthDate.chineseMonthName
        
        return HStack(spacing: 0) {
            // 左侧月份标签
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(width: 96, height: 128)
                .overlay(
                    Text(monthName)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                )
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .trailing
                )
            
            // 日期网格
            ForEach(0..<columnsCount, id: \.self) { colIndex in
                let dayNumber = colIndex - monthStartDayIndex + 1
                let isValidDay = dayNumber > 0 && dayNumber <= daysCount
                let isWeekend = (colIndex % 7 == 0 || colIndex % 7 == 6)
                
                if isValidDay {
                    let currentDateObj = calendar.date(byAdding: .day, value: dayNumber - 1, to: monthDate.startOfMonth)!
                    dayCell(for: currentDateObj, dayNumber: dayNumber, isWeekend: isWeekend)
                } else {
                    emptyCell(isWeekend: isWeekend)
                }
            }
            
            // 右侧月份标签
            Rectangle()
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(width: 96, height: 128)
                .overlay(
                    Text(monthName)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                )
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .leading
                )
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    // 日期单元格
    private func dayCell(for date: Date, dayNumber: Int, isWeekend: Bool) -> some View {
        let dayEvents = events.filter { $0.occursOn(date: date) }
            .sorted { $0.startDate < $1.startDate }
        let isToday = date.isToday
        let isSelected = isDateSelected(date)
        
        return Rectangle()
            .fill(backgroundColor(for: date, isWeekend: isWeekend, isSelected: isSelected))
            .frame(width: 56, height: 128) // 增加宽度以确保内容显示完整
            .overlay(
                VStack(spacing: 2) {
                    // 日期数字
                    Button(action: {
                        onDateClick(date)
                    }) {
                        Text("\(dayNumber)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isToday ? .white : .secondary)
                            .frame(width: 24, height: 24)
                            .background(isToday ? Color.blue : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 事件列表
                    VStack(spacing: 1) {
                        ForEach(Array(dayEvents.prefix(4).enumerated()), id: \.element.id) { index, event in
                            eventBar(for: event, date: date)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 6)
                .padding(.horizontal, 2)
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                // 双击创建事件
                onCreateEvent(date, nil)
            }
            .gesture(
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
            )
    }
    
    // 空单元格
    private func emptyCell(isWeekend: Bool) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .frame(width: 56, height: 128)
            .overlay(
                // 斜纹图案 - 只在空单元格中显示
                ZStack {
                    Path { path in
                        for i in stride(from: -128, through: 56, by: 12) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + 128, y: 128))
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color.gray.opacity(0.1)),
                alignment: .trailing
            )
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
            Rectangle()
                .fill(event.color)
                .frame(height: 14) // 稍微增加高度
                .overlay(
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
                )
                .cornerRadius(continuesPrev && continuesNext ? 0 : 3)
        }
        .buttonStyle(PlainButtonStyle())
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