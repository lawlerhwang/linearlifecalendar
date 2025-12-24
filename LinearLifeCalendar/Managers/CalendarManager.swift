import Foundation
import SwiftUI

@MainActor
class CalendarManager: ObservableObject {
    // 移除EventKit相关功能，禁用iCloud日历访问
    
    @Published var events: [CalendarEvent] = []
    @Published var hasCalendarAccess = false // 始终为false，禁用日历访问
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 禁用日历访问权限请求
    func requestCalendarAccess() {
        // 不再请求日历权限，直接设置为无权限状态
        hasCalendarAccess = false
        errorMessage = "此应用已禁用iCloud日历访问功能"
    }
    
    // 禁用事件加载功能
    func loadEvents(from startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                   to endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!) {
        // 不再从系统日历加载事件
        events = []
        errorMessage = "iCloud日历访问已被禁用"
    }
    
    // 禁用事件创建功能
    func createEvent(title: String,
                    startDate: Date,
                    endDate: Date,
                    isAllDay: Bool = false,
                    location: String? = nil,
                    notes: String? = nil) {
        // 不再创建系统日历事件
        errorMessage = "无法创建事件：iCloud日历访问已被禁用"
    }
    
    // 禁用事件删除功能
    func deleteEvent(withId eventId: String) {
        // 不再删除系统日历事件
        errorMessage = "无法删除事件：iCloud日历访问已被禁用"
    }
    
    // 获取指定日期的事件（现在返回空数组）
    func events(for date: Date) -> [CalendarEvent] {
        return [] // 不再返回系统日历事件
    }
    
    // 禁用获取可用日历列表功能
    func getAvailableCalendars() -> [Any] { // 改为Any类型避免EKCalendar依赖
        return [] // 不再返回系统日历列表
    }
}