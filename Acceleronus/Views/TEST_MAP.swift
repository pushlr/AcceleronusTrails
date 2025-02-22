//  ContentView.swift
import SwiftUI

// A preference key to store ScrollView offset
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
struct ContentView: View {
    @Environment(\.refresh) private var refresh
    @State private var isCurrentlyRefreshing = false
    let amountToPullBeforeRefreshing: CGFloat = 180
    func refreshData() async {
        // do work to asyncronously refresh your data here
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }
    
    var body: some View {
        ScrollView {
            if isCurrentlyRefreshing {
                ProgressView()
            }
            
            LazyVGrid(columns: [GridItem(.flexible())]) {
                ForEach(0...100, id: \.self) { index in
                    Text("row \(index)")
                        .padding()
                        .frame(width: .infinity)
                }
            }
            // the geometry proxy allows us to detect how far on the list we have scrolled
            // and will update the ViewOffsetKey once the "if" conditions are met
            .overlay(GeometryReader { geo in
                let currentScrollViewPosition = -geo.frame(in: .global).origin.y
                
                if currentScrollViewPosition < -amountToPullBeforeRefreshing && !isCurrentlyRefreshing {
                    Color.clear.preference(key: ViewOffsetKey.self, value: -geo.frame(in: .global).origin.y)
                }
            })
        }
        // The onPreferenceChange listens for the ViewOffsetKey to change to know when to run the pull to refresh method
        .onPreferenceChange(ViewOffsetKey.self) { scrollPosition in
            if scrollPosition < -amountToPullBeforeRefreshing && !isCurrentlyRefreshing {
                isCurrentlyRefreshing = true
                Task {
                    await refreshData()
                    await MainActor.run {
                        isCurrentlyRefreshing = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
