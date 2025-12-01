import SwiftUICore
import SwiftUI

import SwiftUI

struct MapMenuControl<Content: View>: View {
    // MARK: - Parameters
    
    // Label
    var iconName: String
    var labelText: String
    var foregroundStyle: Color
    var isLoading: Bool = false
    
    // Menu content
    let menuContent: Content
    
    // MARK: - Init
    init(
        iconName: String,
        labelText: String,
        foregroundStyle: Color,
        isLoading: Bool = false,
        @ViewBuilder menuContent: () -> Content
    ) {
        self.iconName = iconName
        self.labelText = labelText
        self.foregroundStyle = foregroundStyle
        self.isLoading = isLoading
        self.menuContent = menuContent()
    }
    
    // MARK: - Body
    var body: some View {
        Menu {
            menuContent
        } label: {
            HStack(spacing: 5) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                } else {
                    Text(labelText)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .frame(height: 45)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.12), lineWidth: 0.6)
            )
            .foregroundStyle(foregroundStyle)
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
        }
    }
}
