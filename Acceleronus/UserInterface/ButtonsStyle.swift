//
//  ButtonsStyle.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 15.10.2023.
//

import Foundation
import SwiftUI


struct ButtonDefault: ButtonStyle {
    var Disabled: Bool = false
    var ButtonColor : Color
    var width = 150.0
    var maxWidth = 300
    var height = 50.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width,height: height)
           // .padding()
            .foregroundColor(Color.white)
          //  .padding(.horizontal, width / 2)
            .background(Disabled ? Color.gray : ButtonColor)
            .cornerRadius(8)
            .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : Color.white)
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
        
    }
}




