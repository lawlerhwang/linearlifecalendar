import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) private var dismiss
    
    let initialDate: Date
    let initialEndDate: Date?
    
    @State private var title = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var location = ""
    @State private var notes = ""
    
    init(initialDate: Date, initialEndDate: Date? = nil) {
        self.initialDate = initialDate
        self.initialEndDate = initialEndDate
        
        // 初始化状态
        _startDate = State(initialValue: initialDate)
        
        if let endDate = initialEndDate {
            _endDate = State(initialValue: endDate)
            _isAllDay = State(initialValue: true)
        } else {
            let calendar = Calendar.current
            let nextHour = calendar.date(byAdding: .hour, value: 1, to: initialDate) ?? initialDate
            _endDate = State(initialValue: nextHour)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题输入
            titleSection
            
            // 时间设置
            timeSection
            
            // 详细信息
            detailsSection
            
            Spacer()
            
            // 底部按钮栏 (macOS 风格)
            HStack {
                Spacer()
                
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("保存") {
                    saveEvent()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
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
        .padding(20)
        .frame(width: 480, height: 600)
        .navigationTitle("新建日程")
    }
    
    // 标题输入区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("日程标题", text: $title)
                .font(.title2)
                .fontWeight(.medium)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.bottom, 4)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.blue)
        }
        .padding(.bottom, 24)
    }
    
    // 时间设置区域
    private var timeSection: some View {
        VStack(spacing: 16) {
            // 全天开关
            HStack {
                Toggle("全天", isOn: $isAllDay)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }
            
            // 开始时间
            HStack {
                Text("开始")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                VStack(spacing: 8) {
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    if !isAllDay {
                        DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }
                
                Spacer()
            }
            
            // 结束时间
            HStack {
                Text("结束")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                VStack(spacing: 8) {
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    if !isAllDay {
                        DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .onChange(of: isAllDay) { newValue in
            if newValue {
                // 设置为全天时，调整时间
                let calendar = Calendar.current
                startDate = calendar.startOfDay(for: startDate)
                endDate = calendar.startOfDay(for: endDate)
            }
        }
    }
    
    // 详细信息区域
    private var detailsSection: some View {
        VStack(spacing: 16) {
            // 地点
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("添加地点", text: $location)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // 备注
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("添加描述")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .font(.system(size: 14))
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.top, 24)
    }
    
    // 显示禁用信息而不是保存事件
    private func saveEvent() {
        // 显示禁用信息
        calendarManager.errorMessage = "事件创建已禁用：此应用不再访问iCloud日历"
        dismiss()
    }
}

#Preview {
    CreateEventView(initialDate: Date())
        .environmentObject(CalendarManager())
}