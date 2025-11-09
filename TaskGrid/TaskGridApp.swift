//
//  TaskGridApp.swift
//  TaskGrid
//
//  Created by Nishil Soni on 09/11/25.
//
import SwiftUI
import UserNotifications
@main
struct TaskGridApp: App {
    @StateObject private var store = TaskStore()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
