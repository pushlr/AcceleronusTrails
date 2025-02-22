//
//  SignalStrengthIndicator_SubView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 12.11.2023.
//

import SwiftUI

struct Divided<S: Shape>: Shape {
    var amount: CGFloat // Should be in range 0...1
    var shape: S
    func path(in rect: CGRect) -> Path {
        shape.path(in: rect.divided(atDistance: amount * rect.height, from: .maxYEdge).slice)
    }
}

extension Shape {
    func divided(amount: CGFloat) -> Divided<Self> {
        return Divided(amount: amount, shape: self)
    }
}


struct SignalStrengthIndicator_SubView: View {
    
       var strenght: Int = 3
       var totalBars: Int = 5
       
        var body: some View {
           HStack(spacing: 1) {
               ForEach(0..<totalBars) { bar in
                   RoundedRectangle(cornerRadius: 2)
                       .divided(amount: (CGFloat(bar) + 1) / CGFloat(self.totalBars))
                       .fill(Color.blue.opacity(bar < self.strenght ? 1 : 0.3))
               }
           }
       }
    
    
}

#Preview {
    SignalStrengthIndicator_SubView().frame(width:50,height: 25)
}
