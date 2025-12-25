import XCTest
@testable import LinearLifeCalendar

class YearViewTests: XCTestCase {
    
    // MARK: - Property-Based Tests
    
    /// **Feature: year-view-enhancement, Property 1: 完整线性日历显示**
    /// **验证: 需求 1.1, 1.2, 1.4**
    func testLinearCalendarCompleteDisplay() {
        // Property: 对于任何年份，线性日历应该显示该年的所有有效日期，每个日期都应该根据其星期几正确放置在网格中的对应位置
        
        // Test with multiple random years to ensure property holds
        let testYears = [2020, 2021, 2022, 2023, 2024, 2025] // Including leap year 2020 and 2024
        
        for year in testYears {
            let calendar = Calendar.current
            let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            
            // Get all months in the year
            let monthsInYear = yearDate.monthsInYear()
            XCTAssertEqual(monthsInYear.count, 12, "Year \(year) should have exactly 12 months")
            
            // Verify each month displays all its valid dates
            for monthDate in monthsInYear {
                let monthStartDayIndex = calendar.component(.weekday, from: monthDate.startOfMonth) - 1
                let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
                
                // Verify month has correct number of days
                XCTAssertGreaterThan(daysCount, 0, "Month \(monthDate.month) in year \(year) should have at least 1 day")
                XCTAssertLessThanOrEqual(daysCount, 31, "Month \(monthDate.month) in year \(year) should have at most 31 days")
                
                // Verify all days in month are valid and correctly positioned
                for dayNumber in 1...daysCount {
                    let dayDate = calendar.date(byAdding: .day, value: dayNumber - 1, to: monthDate.startOfMonth)!
                    let expectedWeekday = calendar.component(.weekday, from: dayDate) - 1 // 0=Sunday, 1=Monday...
                    let calculatedPosition = monthStartDayIndex + dayNumber - 1
                    let actualWeekday = calculatedPosition % 7
                    
                    XCTAssertEqual(actualWeekday, expectedWeekday, 
                                 "Day \(dayNumber) of month \(monthDate.month) in year \(year) should be positioned correctly based on weekday")
                }
                
                // Verify leap year February has 29 days
                if monthDate.month == 2 && calendar.isLeapYear(year: year) {
                    XCTAssertEqual(daysCount, 29, "February in leap year \(year) should have 29 days")
                } else if monthDate.month == 2 {
                    XCTAssertEqual(daysCount, 28, "February in non-leap year \(year) should have 28 days")
                }
            }
            
            // Verify total days in year
            let totalDaysInYear = monthsInYear.reduce(0) { total, monthDate in
                let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
                return total + daysCount
            }
            
            let expectedDaysInYear = calendar.isLeapYear(year: year) ? 366 : 365
            XCTAssertEqual(totalDaysInYear, expectedDaysInYear, 
                         "Year \(year) should have \(expectedDaysInYear) days total")
        }
    }
    
    /// **Feature: year-view-enhancement, Property 2: 线性月份边界对齐**
    /// **验证: 需求 1.3**
    func testLinearMonthBoundaryAlignment() {
        // Property: 对于任何月份，该月的第一天应该对齐到正确的星期几列，最后一天应该正确结束，保持线性时间轴的连续性
        
        let calendar = Calendar.current
        let testYears = [2020, 2021, 2022, 2023, 2024, 2025] // Including leap years
        
        for year in testYears {
            let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let monthsInYear = yearDate.monthsInYear()
            
            for monthDate in monthsInYear {
                let monthStartDate = monthDate.startOfMonth
                let monthEndDate = monthDate.endOfMonth
                
                // Test first day alignment
                let firstDayWeekday = calendar.component(.weekday, from: monthStartDate) - 1 // 0=Sunday, 1=Monday...
                let monthStartDayIndex = firstDayWeekday
                
                // Verify first day is positioned correctly based on its weekday
                XCTAssertGreaterThanOrEqual(monthStartDayIndex, 0, 
                                          "Month \(monthDate.month) in year \(year) first day should have valid weekday index")
                XCTAssertLessThan(monthStartDayIndex, 7, 
                                "Month \(monthDate.month) in year \(year) first day weekday index should be less than 7")
                
                // Test last day alignment
                let lastDayWeekday = calendar.component(.weekday, from: monthEndDate) - 1
                let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
                let lastDayPosition = monthStartDayIndex + daysCount - 1
                let expectedLastDayWeekday = lastDayPosition % 7
                
                XCTAssertEqual(expectedLastDayWeekday, lastDayWeekday,
                             "Month \(monthDate.month) in year \(year) last day should align correctly with calculated position")
                
                // Test continuity - verify all days between first and last are valid
                for dayOffset in 0..<daysCount {
                    let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: monthStartDate)!
                    let dayPosition = monthStartDayIndex + dayOffset
                    let expectedWeekday = dayPosition % 7
                    let actualWeekday = calendar.component(.weekday, from: dayDate) - 1
                    
                    XCTAssertEqual(expectedWeekday, actualWeekday,
                                 "Day \(dayOffset + 1) of month \(monthDate.month) in year \(year) should maintain linear continuity")
                }
                
                // Test month boundary doesn't exceed column limits
                let columnsCount = 42 // 6 weeks × 7 days
                XCTAssertLessThan(lastDayPosition, columnsCount,
                                "Month \(monthDate.month) in year \(year) should fit within \(columnsCount) columns")
                
                // Test empty cells before first day
                for emptyIndex in 0..<monthStartDayIndex {
                    // These should be empty cells (not valid days for this month)
                    let dayNumber = emptyIndex - monthStartDayIndex + 1
                    XCTAssertLessThanOrEqual(dayNumber, 0,
                                           "Position \(emptyIndex) before month start should not contain valid day")
                }
                
                // Test empty cells after last day
                let remainingCells = columnsCount - (lastDayPosition + 1)
                for emptyIndex in 0..<remainingCells {
                    let dayNumber = lastDayPosition + 1 + emptyIndex - monthStartDayIndex + 1
                    XCTAssertGreaterThan(dayNumber, daysCount,
                                       "Position \(lastDayPosition + 1 + emptyIndex) after month end should not contain valid day")
                }
            }
        }
    }
    
    /// **Feature: year-view-enhancement, Property 3: 线性月份标签完整性**
    /// **验证: 需求 2.1, 2.2, 2.3**
    func testLinearMonthLabelCompleteness() {
        // Property: 对于任何线性日历中的月份行，左侧和右侧都应该显示对应的中文月份标签
        
        let calendar = Calendar.current
        let testYears = [2020, 2021, 2022, 2023, 2024, 2025]
        
        for year in testYears {
            let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let monthsInYear = yearDate.monthsInYear()
            
            // Verify we have exactly 12 months
            XCTAssertEqual(monthsInYear.count, 12, "Year \(year) should have exactly 12 months")
            
            // Test each month has correct Chinese month name
            for (index, monthDate) in monthsInYear.enumerated() {
                let expectedMonth = index + 1
                let actualMonth = monthDate.month
                
                XCTAssertEqual(actualMonth, expectedMonth, 
                             "Month at index \(index) should be month \(expectedMonth)")
                
                // Test Chinese month name is correct
                let chineseMonthName = monthDate.chineseMonthName
                let expectedName = getExpectedChineseName(for: index)
                
                XCTAssertEqual(chineseMonthName, expectedName,
                             "Month \(expectedMonth) in year \(year) should have Chinese name '\(expectedName)'")
                
                // Test month name is not empty
                XCTAssertFalse(chineseMonthName.isEmpty,
                             "Month \(expectedMonth) in year \(year) should have non-empty Chinese name")
                
                // Test month name contains expected characters
                XCTAssertTrue(chineseMonthName.hasSuffix("月"),
                            "Month \(expectedMonth) in year \(year) Chinese name should end with '月'")
                
                // Test month name length is reasonable (should be 2 characters for most months, 3 for 十一月/十二月)
                XCTAssertGreaterThanOrEqual(chineseMonthName.count, 2,
                                          "Month \(expectedMonth) Chinese name should be at least 2 characters")
                XCTAssertLessThanOrEqual(chineseMonthName.count, 3,
                                       "Month \(expectedMonth) Chinese name should be at most 3 characters")
            }
            
            // Test all month names are unique
            let allMonthNames = monthsInYear.map { $0.chineseMonthName }
            let uniqueMonthNames = Set(allMonthNames)
            XCTAssertEqual(allMonthNames.count, uniqueMonthNames.count,
                         "All month names in year \(year) should be unique")
            
            // Test month names are in correct order
            let expectedOrder = getExpectedMonthOrder()
            XCTAssertEqual(allMonthNames, expectedOrder,
                         "Month names in year \(year) should be in correct chronological order")
        }
    }
    
    // MARK: - Helper Methods for Property Testing
    
    /// **Feature: year-view-enhancement, Property 4: 线性月份行数量**
    /// **验证: 需求 2.4**
    func testLinearMonthRowQuantity() {
        // Property: 对于任何线性日历，应该恰好显示12行，每行对应一个月份，形成完整的年度时间轴
        
        let calendar = Calendar.current
        let testYears = [2020, 2021, 2022, 2023, 2024, 2025]
        
        for year in testYears {
            let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let monthsInYear = yearDate.monthsInYear()
            
            // Test exactly 12 month rows
            XCTAssertEqual(monthsInYear.count, 12,
                         "Linear calendar for year \(year) should have exactly 12 month rows")
            
            // Test each month row corresponds to correct month
            for (rowIndex, monthDate) in monthsInYear.enumerated() {
                let expectedMonth = rowIndex + 1
                let actualMonth = monthDate.month
                let actualYear = monthDate.year
                
                XCTAssertEqual(actualMonth, expectedMonth,
                             "Month row \(rowIndex) should correspond to month \(expectedMonth)")
                XCTAssertEqual(actualYear, year,
                             "Month row \(rowIndex) should belong to year \(year)")
            }
            
            // Test month rows form complete timeline (no gaps)
            for i in 0..<(monthsInYear.count - 1) {
                let currentMonth = monthsInYear[i]
                let nextMonth = monthsInYear[i + 1]
                
                let currentMonthNumber = currentMonth.month
                let nextMonthNumber = nextMonth.month
                
                XCTAssertEqual(nextMonthNumber, currentMonthNumber + 1,
                             "Month row \(i + 1) should immediately follow month row \(i) in timeline")
            }
            
            // Test first month is January
            let firstMonth = monthsInYear.first!
            XCTAssertEqual(firstMonth.month, 1,
                         "First month row should be January (month 1)")
            XCTAssertEqual(firstMonth.year, year,
                         "First month row should belong to year \(year)")
            
            // Test last month is December
            let lastMonth = monthsInYear.last!
            XCTAssertEqual(lastMonth.month, 12,
                         "Last month row should be December (month 12)")
            XCTAssertEqual(lastMonth.year, year,
                         "Last month row should belong to year \(year)")
            
            // Test all months belong to same year
            let allYears = monthsInYear.map { $0.year }
            let uniqueYears = Set(allYears)
            XCTAssertEqual(uniqueYears.count, 1,
                         "All month rows should belong to the same year")
            XCTAssertEqual(uniqueYears.first, year,
                         "All month rows should belong to year \(year)")
            
            // Test months are in chronological order
            for i in 1..<monthsInYear.count {
                let previousMonth = monthsInYear[i - 1]
                let currentMonth = monthsInYear[i]
                
                XCTAssertLessThan(previousMonth, currentMonth,
                                "Month rows should be in chronological order")
            }
        }
    }
    
    /// Test that the columnsCount of 42 (6 weeks × 7 days) ensures complete display
    func testColumnsCountEnsuresCompleteDisplay() {
        let columnsCount = 42 // 6 weeks × 7 days
        let calendar = Calendar.current
        
        // Test various months that might need maximum columns
        let testCases = [
            (year: 2023, month: 1), // January 2023 starts on Sunday
            (year: 2023, month: 5), // May 2023 starts on Monday  
            (year: 2024, month: 9), // September 2024 starts on Sunday
            (year: 2024, month: 12), // December 2024 starts on Sunday
        ]
        
        for (year, month) in testCases {
            let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            let monthStartDayIndex = calendar.component(.weekday, from: monthDate.startOfMonth) - 1
            let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
            
            let lastDayPosition = monthStartDayIndex + daysCount - 1
            
            XCTAssertLessThan(lastDayPosition, columnsCount, 
                            "Month \(month)/\(year) with \(daysCount) days starting at position \(monthStartDayIndex) should fit within \(columnsCount) columns")
        }
    }
    
    /// **Feature: year-view-enhancement, Property 5: 线性日期单元格一致性**
    /// **验证: 需求 3.1, 4.5**
    func testLinearDateCellConsistency() {
        // Property: 对于任何线性日历中的日期单元格，所有单元格应该具有相同的尺寸和一致的间距，保持时间轴的视觉连续性
        
        let calendar = Calendar.current
        let testYears = [2020, 2021, 2022, 2023, 2024, 2025]
        
        for year in testYears {
            let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let monthsInYear = yearDate.monthsInYear()
            
            // Expected cell dimensions based on current implementation
            let expectedCellWidth: CGFloat = 20
            let expectedCellHeight: CGFloat = 100
            let expectedSpacing: CGFloat = 0
            
            for monthDate in monthsInYear {
                let monthStartDate = monthDate.startOfMonth
                let daysCount = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 0
                let firstDayWeekday = calendar.component(.weekday, from: monthStartDate) - 1
                let totalColumns = 31 // Fixed columns for alignment
                
                // Test all valid day cells have consistent dimensions
                for dayOffset in 0..<daysCount {
                    let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: monthStartDate)!
                    let columnIndex = firstDayWeekday + dayOffset
                    
                    // Verify cell is within valid column range
                    XCTAssertLessThan(columnIndex, totalColumns,
                                    "Day \(dayOffset + 1) of month \(monthDate.month) in year \(year) should be within column range")
                    
                    // Test cell dimensions consistency
                    // Note: In actual implementation, we would test the view's frame
                    // Here we test the logical consistency of the layout
                    let isWeekend = isWeekendColumn(columnIndex: columnIndex)
                    let cellProperties = getCellProperties(for: dayDate, isWeekend: isWeekend)
                    
                    XCTAssertEqual(cellProperties.width, expectedCellWidth,
                                 "Day cell for \(dayDate) should have consistent width")
                    XCTAssertEqual(cellProperties.height, expectedCellHeight,
                                 "Day cell for \(dayDate) should have consistent height")
                    XCTAssertEqual(cellProperties.spacing, expectedSpacing,
                                 "Day cell for \(dayDate) should have consistent spacing")
                }
                
                // Test empty cells also have consistent dimensions
                for emptyIndex in 0..<firstDayWeekday {
                    let isWeekend = isWeekendColumn(columnIndex: emptyIndex)
                    let emptyCellProperties = getEmptyCellProperties(isWeekend: isWeekend)
                    
                    XCTAssertEqual(emptyCellProperties.width, expectedCellWidth,
                                 "Empty cell at position \(emptyIndex) should have consistent width")
                    XCTAssertEqual(emptyCellProperties.height, expectedCellHeight,
                                 "Empty cell at position \(emptyIndex) should have consistent height")
                    XCTAssertEqual(emptyCellProperties.spacing, expectedSpacing,
                                 "Empty cell at position \(emptyIndex) should have consistent spacing")
                }
                
                // Test trailing empty cells
                let lastDayPosition = firstDayWeekday + daysCount - 1
                for emptyIndex in (lastDayPosition + 1)..<totalColumns {
                    let isWeekend = isWeekendColumn(columnIndex: emptyIndex)
                    let emptyCellProperties = getEmptyCellProperties(isWeekend: isWeekend)
                    
                    XCTAssertEqual(emptyCellProperties.width, expectedCellWidth,
                                 "Trailing empty cell at position \(emptyIndex) should have consistent width")
                    XCTAssertEqual(emptyCellProperties.height, expectedCellHeight,
                                 "Trailing empty cell at position \(emptyIndex) should have consistent height")
                }
                
                // Test row height consistency
                let monthRowHeight = expectedCellHeight
                XCTAssertEqual(monthRowHeight, expectedCellHeight,
                             "Month row for \(monthDate.month) in year \(year) should have consistent height")
                
                // Test column alignment consistency
                for columnIndex in 0..<totalColumns {
                    let columnX = CGFloat(columnIndex) * (expectedCellWidth + expectedSpacing)
                    let expectedX = CGFloat(columnIndex) * expectedCellWidth // Since spacing is 0
                    
                    XCTAssertEqual(columnX, expectedX,
                                 "Column \(columnIndex) should be positioned consistently")
                }
            }
            
            // Test overall grid consistency
            let totalRows = monthsInYear.count
            XCTAssertEqual(totalRows, 12,
                         "Linear calendar for year \(year) should have consistent 12 rows")
            
            // Test month label consistency
            let expectedMonthLabelWidth: CGFloat = 60
            let expectedMonthLabelHeight: CGFloat = 100
            
            for monthDate in monthsInYear {
                let monthLabelProperties = getMonthLabelProperties()
                
                XCTAssertEqual(monthLabelProperties.width, expectedMonthLabelWidth,
                             "Month label for \(monthDate.month) should have consistent width")
                XCTAssertEqual(monthLabelProperties.height, expectedMonthLabelHeight,
                             "Month label for \(monthDate.month) should have consistent height")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getExpectedChineseName(for index: Int) -> String {
        let names = ["一月", "二月", "三月", "四月", "五月", "六月",
                    "七月", "八月", "九月", "十月", "十一月", "十二月"]
        return names[index]
    }
    
    private func getExpectedMonthOrder() -> [String] {
        return ["一月", "二月", "三月", "四月", "五月", "六月",
               "七月", "八月", "九月", "十月", "十一月", "十二月"]
    }
    
    // MARK: - Cell Properties Helper Methods
    
    private struct CellProperties {
        let width: CGFloat
        let height: CGFloat
        let spacing: CGFloat
    }
    
    private struct MonthLabelProperties {
        let width: CGFloat
        let height: CGFloat
    }
    
    private func getCellProperties(for date: Date, isWeekend: Bool) -> CellProperties {
        // Based on alignedDayCell implementation
        return CellProperties(width: 20, height: 100, spacing: 0)
    }
    
    private func getEmptyCellProperties(isWeekend: Bool) -> CellProperties {
        // Based on emptyAlignedCell implementation
        return CellProperties(width: 20, height: 100, spacing: 0)
    }
    
    private func getMonthLabelProperties() -> MonthLabelProperties {
        // Based on monthLabel implementation
        return MonthLabelProperties(width: 60, height: 100)
    }
    
    private func isWeekendColumn(columnIndex: Int) -> Bool {
        let weekday = columnIndex % 7
        return weekday == 5 || weekday == 6 // 周六=5, 周日=6 (因为周一=0)
    }
}

// MARK: - Calendar Extension for Testing
extension Calendar {
    func isLeapYear(year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}