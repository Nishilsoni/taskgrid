//
//  ContentView.swift
//  TaskGrid
//
//  Created by Nishil Soni on 09/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 12) {
                Text("TaskGrid").font(.largeTitle).bold().foregroundColor(.primary)
                Text("A focused, beautiful task board").foregroundColor(Color.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color("Primary")))
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
