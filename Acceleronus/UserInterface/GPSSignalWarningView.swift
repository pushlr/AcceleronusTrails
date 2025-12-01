//
//  GPSSignalWarningView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 25.11.2025.
//
import SwiftUI

struct GPSSignalWarningView: View {
    @Binding var isVisible: Bool  // control when to show/hide

    var body: some View {
        if isVisible {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Weak GPS Signal")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial) // elegant blur / translucent background
            .clipShape(Capsule())
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)  // make sure it’s above the map
        }
    }
}
