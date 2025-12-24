import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var currentDate = Date()
    @State private var selectedView: ViewType = .year
    @State private var showingCreateEvent = false
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    @State private var selectedDate: Date?
    @State private var selectedEndDate: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            navigationBar
            
            // 主内容区域
            mainContent
        }
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                initialDate: selectedDate ?? Date(),
                initialEndDate: selectedEndDate
            )
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event)
            }
        }
        .alert("错误", isPresented: .constant(calendarManager.errorMessage != nil)) {
            Button("确定") {
                calendarManager.errorMessage = nil
            }
        } message: {
            Text(calendarManager.errorMessage ?? "")
        }
    }
    
    // 顶部导航栏
    private var navigationBar: some View {
        HStack {
            // 左侧：应用标题和视图切换
            HStack(spacing: 16) {
                // 应用标题
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Linear Life")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.serif)
                }
                
                Divider()
                    .frame(height: 20)
                
                // 视图切换按钮
                HStack(spacing: 4) {
                    ForEach(ViewType.allCases, id: \.self) { viewType in
                        Button(viewType.rawValue) {
                            selectedView = viewType
                        }
                        .buttonStyle(ViewSwitchButtonStyle(isSelected: selectedView == viewType))
                    }
                }
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // 右侧：导航控制和添加按钮
            HStack(spacing: 12) {
                // 导航按钮
                HStack(spacing: 8) {
                    Button(action: navigatePrevious) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(NavigationButtonStyle())
                    
                    Button("今天") {
                        currentDate = Date()
                    }
                    .buttonStyle(TodayButtonStyle())
                    
                    Button(action: navigateNext) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(NavigationButtonStyle())
                }
                
                // 当前日期显示
                if selectedView != .year {
                    Text(dateTitle)
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(minWidth: 120)
                }
                
                // 添加事件按钮
                Button(action: {
                    selectedDate = Date()
                    selectedEndDate = nil
                    showingCreateEvent = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("添加日历")
                    }
                }
                .buttonStyle(AddButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    // 主内容区域
    private var mainContent: some View {
        Group {
            if !calendarManager.hasCalendarAccess {
                accessDeniedView
            } else if calendarManager.isLoading {
                loadingView
            } else {
                switch selectedView {
                case .year:
                    YearView(
                        currentDate: currentDate,
                        events: calendarManager.events,
                        onDateClick: handleDateClick,
                        onCreateEvent: handleCreateEvent,
                        onEventClick: handleEventClick
                    )
                case .month:
                    MonthView(
                        currentDate: currentDate,
                        events: calendarManager.events,
                        onDateClick: handleDateClick,
                        onCreateEvent: handleCreateEvent,
                        onEventClick: handleEventClick
                    )
                case .week, .day:
                    // 暂时显示占位符
                    Text("即将推出 \(selectedView.rawValue) 视图")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    // 日历访问已禁用视图
    private var accessDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.minus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("iCloud日历访问已禁用")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("此应用已禁用对系统日历的访问权限，无法显示或管理iCloud日历事件")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("您可以使用应用内的日历功能来管理本地事件")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("正在加载日历事件...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 计算日期标题
    private var dateTitle: String {
        switch selectedView {
        case .year:
            return ""
        case .month:
            return "\(currentDate.year)年\(currentDate.month)月"
        case .week:
            return "\(currentDate.year)年 \(currentDate.month)月"
        case .day:
            return "\(currentDate.year)年\(currentDate.month)月\(currentDate.day)日"
        }
    }
    
    // 导航到上一个时间段
    private func navigatePrevious() {
        let calendar = Calendar.current
        switch selectedView {
        case .year:
            currentDate = calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        case .day:
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    // 导航到下一个时间段
    private func navigateNext() {
        let calendar = Calendar.current
        switch selectedView {
        case .year:
            currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        case .day:
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    // 处理日期点击
    private func handleDateClick(_ date: Date) {
        currentDate = date
        selectedView = .day
    }
    
    // 处理创建事件
    private func handleCreateEvent(startDate: Date, endDate: Date? = nil) {
        selectedDate = startDate
        selectedEndDate = endDate
        showingCreateEvent = true
    }
    
    // 处理事件点击
    private func handleEventClick(_ event: CalendarEvent) {
        selectedEvent = event
        showingEventDetail = true
    }
}

// 自定义按钮样式
struct ViewSwitchButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear)
            .foregroundColor(isSelected ? .blue : .secondary)
            .cornerRadius(6)
            .shadow(color: isSelected ? .black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16))
            .padding(8)
            .background(Color.gray.opacity(configuration.isPressed ? 0.2 : 0.1))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TodayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(configuration.isPressed ? 0.2 : 0.1))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarManager())
}