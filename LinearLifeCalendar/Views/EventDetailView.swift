import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) private var dismiss
    
    let event: CalendarEvent
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 事件标题
                    titleSection
                    
                    // 时间信息
                    timeSection
                    
                    // 地点信息
                    if let location = event.location, !location.isEmpty {
                        locationSection(location)
                    }
                    
                    // 描述信息
                    if let notes = event.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            
            // 底部按钮栏 (macOS 风格)
            HStack {
                Button("删除") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
                .keyboardShortcut(.delete)
                
                Spacer()
                
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .top
            )
        }
        .frame(width: 400, height: 500)
        .navigationTitle("事件详情")
        .alert("删除事件", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("确定要删除这个事件吗？此操作无法撤销。")
        }
    }
    
    // 标题区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Rectangle()
                    .fill(event.color)
                    .frame(width: 4, height: 24)
                
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(nil)
                
                Spacer()
            }
        }
    }
    
    // 时间区域
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    if event.isAllDay {
                        if event.isMultiDay {
                            Text("\(formatDate(event.startDate)) - \(formatDate(event.endDate))")
                                .font(.system(size: 15, weight: .medium))
                        } else {
                            Text(formatDate(event.startDate))
                                .font(.system(size: 15, weight: .medium))
                        }
                        Text("全天")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        if Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
                            // 同一天
                            Text(formatDate(event.startDate))
                                .font(.system(size: 15, weight: .medium))
                            Text("\(formatTime(event.startDate)) - \(formatTime(event.endDate))")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        } else {
                            // 跨天
                            Text("\(formatDateTime(event.startDate)) -")
                                .font(.system(size: 15, weight: .medium))
                            Text(formatDateTime(event.endDate))
                                .font(.system(size: 15, weight: .medium))
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // 地点区域
    private func locationSection(_ location: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "location")
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(location)
                .font(.system(size: 15))
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // 描述区域
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text("描述")
                    .font(.system(size: 15, weight: .medium))
                
                Spacer()
            }
            
            Text(notes)
                .font(.system(size: 14))
                .lineLimit(nil)
                .padding(.leading, 32)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // 删除事件
    private func deleteEvent() {
        calendarManager.deleteEvent(withId: event.id)
        dismiss()
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
    
    // 格式化时间
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // 格式化日期时间
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    EventDetailView(
        event: CalendarEvent(
            title: "产品发布会",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            location: "会议室A",
            notes: "年度旗舰产品发布，全员必须参加。",
            color: .red
        )
    )
    .environmentObject(CalendarManager())
}