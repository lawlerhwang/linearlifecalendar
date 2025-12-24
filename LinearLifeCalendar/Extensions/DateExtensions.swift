import Foundation

extension Date {
    // 获取年份
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    // 获取月份
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    // 获取日期
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    // 获取星期几 (1=周日, 2=周一, ..., 7=周六)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    // 获取月份的第一天
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // 获取月份的最后一天
    var endOfMonth: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? self
    }
    
    // 获取年份的第一天
    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // 获取年份的最后一天
    var endOfYear: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear) ?? self
    }
    
    // 获取一天的开始时间
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    // 获取一天的结束时间
    var endOfDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }
    
    // 检查是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    // 检查是否是周末
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
    
    // 获取月份中的所有日期
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let startOfMonth = self.startOfMonth
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    // 获取年份中的所有月份
    func monthsInYear() -> [Date] {
        let calendar = Calendar.current
        let startOfYear = self.startOfYear
        
        return (0..<12).compactMap { month in
            calendar.date(byAdding: .month, value: month, to: startOfYear)
        }
    }
    
    // 格式化为中文日期字符串
    func chineseFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // 获取中文月份名称
    var chineseMonthName: String {
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月",
                         "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return monthNames[month - 1]
    }
    
    // 获取中文星期名称
    var chineseWeekdayName: String {
        let weekdayNames = ["日", "一", "二", "三", "四", "五", "六"]
        return weekdayNames[weekday - 1]
    }
}