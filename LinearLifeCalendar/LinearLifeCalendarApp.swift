import SwiftUI

@main
struct LinearLifeCalendarApp: App {
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
                .onAppear {
                    calendarManager.requestCalendarAccess()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}