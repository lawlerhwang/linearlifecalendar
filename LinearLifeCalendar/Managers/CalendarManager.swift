import Foundation
import SwiftUI
import EventKit

@MainActor
class CalendarManager: ObservableObject {
    // 只读模式：只加载和显示iCloud事件，禁用创建/修改功能
    
    private let eventStore = EKEventStore()
    
    @Published var events: [CalendarEvent] = []
    @Published var hasCalendarAccess = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isReadOnlyMode = true // 标记为只读模式
    
    // 请求日历访问权限（只读）
    func requestCalendarAccess() {
        Task {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    self.hasCalendarAccess = granted
                    if granted {
                        self.loadEvents()
                    } else {
                        self.errorMessage = "需要日历访问权限来显示您的日程安排"
                    }
                }
            } catch {
                await MainActor.run {
                    self.hasCalendarAccess = false
                    self.errorMessage = "请求日历权限时出错: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // 加载事件（只读）
    func loadEvents(from startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                   to endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!) {
        guard hasCalendarAccess else {
            errorMessage = "没有日历访问权限"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                let ekEvents = eventStore.events(matching: predicate)
                
                let calendarEvents = ekEvents.map { ekEvent in
                    CalendarEvent(
                        id: ekEvent.eventIdentifier,
                        title: ekEvent.title ?? "无标题",
                        startDate: ekEvent.startDate,
                        endDate: ekEvent.endDate,
                        isAllDay: ekEvent.isAllDay,
                        location: ekEvent.location,
                        notes: ekEvent.notes,
                        color: Color(ekEvent.calendar.cgColor),
                        calendarIdentifier: ekEvent.calendar.calendarIdentifier
                    )
                }
                
                await MainActor.run {
                    self.events = calendarEvents
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "加载日历事件时出错: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // 禁用事件创建功能（只读模式）
    func createEvent(title: String,
                    startDate: Date,
                    endDate: Date,
                    isAllDay: Bool = false,
                    location: String? = nil,
                    notes: String? = nil) {
        errorMessage = "只读模式：无法创建新事件。此功能已被禁用以保护您的日历数据安全。"
    }
    
    // 禁用事件删除功能（只读模式）
    func deleteEvent(withId eventId: String) {
        errorMessage = "只读模式：无法删除事件。此功能已被禁用以保护您的日历数据安全。"
    }
    
    // 获取指定日期的事件
    func events(for date: Date) -> [CalendarEvent] {
        return events.filter { event in
            event.occursOn(date: date)
        }
    }
    
    // 获取可用日历列表（只读）
    func getAvailableCalendars() -> [EKCalendar] {
        guard hasCalendarAccess else { return [] }
        return eventStore.calendars(for: .event)
    }
    
    // 刷新事件数据
    func refreshEvents() {
        guard hasCalendarAccess else { return }
        loadEvents()
    }
}