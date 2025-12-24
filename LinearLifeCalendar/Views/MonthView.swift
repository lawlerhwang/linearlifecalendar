import SwiftUI

struct MonthView: View {
    let currentDate: Date
    let events: [CalendarEvent]
    let onDateClick: (Date) -> Void
    let onCreateEvent: (Date, Date?) -> Void
    let onEventClick: (CalendarEvent) -> Void
    
    @State private var isDragging = false
    @State private var selectionStart: Date?
    @State private var selectionEnd: Date?
    
    private let dayLabels = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 星期标签
            weekdayHeader
            
            // 日期网格
            monthGrid
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // 星期标签
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(dayLabels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    // 月份网格
    private var monthGrid: some View {
        let calendar = Calendar.current
        let monthStart = currentDate.startOfMonth
        let monthEnd = currentDate.endOfMonth
        
        // 计算网格开始日期（包含上个月的日期）
        let startDate = calendar.dateInterval(of: .weekOfYear, for: monthStart)?.start ?? monthStart
        
        // 计算网格结束日期（包含下个月的日期）
        let endDate = calendar.dateInterval(of: .weekOfYear, for: monthEnd)?.end ?? monthEnd
        
        let allDays = generateDates(from: startDate, to: endDate)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 1) {
            ForEach(allDays, id: \.self) { date in
                dayCell(for: date, isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month))
            }
        }
        .padding(1)
        .background(Color.gray.opacity(0.2))
    }
    
    // 日期单元格
    private func dayCell(for date: Date, isCurrentMonth: Bool) -> some View {
        let dayEvents = events.filter { $0.occursOn(date: date) }
            .sorted { $0.startDate < $1.startDate }
        let isToday = date.isToday
        let isSelected = isDateSelected(date)
        
        return VStack(spacing: 0) {
            // 日期数字
            Button(action: {
                onDateClick(date)
            }) {
                Text("\(date.day)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor(for: date, isCurrentMonth: isCurrentMonth, isToday: isToday))
                    .frame(width: 28, height: 28)
                    .background(isToday ? Color.blue : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // 事件列表
            VStack(spacing: 2) {
                ForEach(Array(dayEvents.prefix(3).enumerated()), id: \.element.id) { index, event in
                    eventPill(for: event)
                }
                
                if dayEvents.count > 3 {
                    Text("+\(dayEvents.count - 3) more")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(minHeight: 100)
        .frame(maxWidth: .infinity)
        .background(backgroundColor(for: date, isCurrentMonth: isCurrentMonth, isSelected: isSelected))
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
    
    // 事件药丸
    private func eventPill(for event: CalendarEvent) -> some View {
        Button(action: {
            onEventClick(event)
        }) {
            Text(event.title)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(event.color)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 文字颜色
    private func textColor(for date: Date, isCurrentMonth: Bool, isToday: Bool) -> Color {
        if isToday {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    // 背景颜色
    private func backgroundColor(for date: Date, isCurrentMonth: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return Color.blue.opacity(0.1)
        } else if !isCurrentMonth {
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
    
    // 生成日期范围
    private func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
}

#Preview {
    MonthView(
        currentDate: Date(),
        events: [],
        onDateClick: { _ in },
        onCreateEvent: { _, _ in },
        onEventClick: { _ in }
    )
    .frame(width: 800, height: 600)
}