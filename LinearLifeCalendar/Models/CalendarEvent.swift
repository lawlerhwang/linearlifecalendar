import Foundation
import SwiftUI
import EventKit

// 视图类型枚举
enum ViewType: String, CaseIterable {
    case day = "日"
    case week = "周" 
    case month = "月"
    case year = "年"
}

// 日历事件模型（支持从EKEvent创建，只读模式）
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
    
    // 从EKEvent创建CalendarEvent（只读）
    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier
        self.title = ekEvent.title ?? "无标题"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.location = ekEvent.location
        self.notes = ekEvent.notes
        self.color = Color(ekEvent.calendar.cgColor)
        self.calendarIdentifier = ekEvent.calendar.calendarIdentifier
    }
    
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