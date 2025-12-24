import Foundation
import SwiftUI

// 视图类型枚举
enum ViewType: String, CaseIterable {
    case day = "日"
    case week = "周" 
    case month = "月"
    case year = "年"
}

// 日历事件模型（已移除EventKit依赖）
struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let notes: String?
    let color: Color
    let calendarIdentifier: String?
    
    // 移除从EKEvent初始化的方法，因为不再使用EventKit
    
    init(id: String = UUID().uuidString,
         title: String,
         startDate: Date,
         endDate: Date,
         isAllDay: Bool = false,
         location: String? = nil,
         notes: String? = nil,
         color: Color = .blue,
         calendarIdentifier: String? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.color = color
        self.calendarIdentifier = calendarIdentifier
    }
    
    // 检查事件是否在指定日期发生
    func occursOn(date: Date) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        return startDate < dayEnd && endDate > dayStart
    }
    
    // 检查事件是否跨越多天
    var isMultiDay: Bool {
        let calendar = Calendar.current
        return !calendar.isDate(startDate, inSameDayAs: endDate)
    }
}