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
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            if isSignedIn {
                HomeView()
                    .environmentObject(store)
                    .preferredColorScheme(.light)
            } else {
                AuthView()
                    .environmentObject(store)
                    .preferredColorScheme(.light)
            }
        }
    }
}
