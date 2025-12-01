//
//  LoadingScreen.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 24.11.2025.
//

import SwiftUICore
import SwiftUI


struct LoadingScreen: View {
    @State private var move1 = false
     @State private var move2 = false
    @State private var move3 = false
     @State private var rotateCompass = false
     
     var body: some View {
         ZStack {
             // Background color
             Color(.systemBackground).ignoresSafeArea()

             // --- MAP FEEL BACKGROUND LAYERS ---
             ZStack {
                 // Blurred map polygons / regions (stylized)
                 RoundedRectangle(cornerRadius: 80)
                     .fill(pastelColors[0].opacity(0.7))
                     .frame(width: 280, height: 250)
                     .rotationEffect(.degrees(15))
                     .offset(x: move1 ? -120 : 100, y: move1 ? -140 : 120)
                     .blur(radius: 40)
                     .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: move1)

                 RoundedRectangle(cornerRadius: 70)
                     .fill(pastelColors[1].opacity(0.7))
                     .frame(width: 260, height: 240)
                     .rotationEffect(.degrees(-20))
                     .offset(x: move2 ? 140 : -100, y: move2 ? 150 : -120)
                     .blur(radius: 40)
                     .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: move2)
                 
                 RoundedRectangle(cornerRadius: 70)
                     .fill(pastelColors[2].opacity(0.7))
                     .frame(width: 160, height: 240)
                     .rotationEffect(.degrees(-20))
                     .offset(x: move3 ? 40 : 100, y: move3 ? 50 : 120)
                     .blur(radius: 40)
                     .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: move3)

                 // Faint route line
                 RoutePathShape()
                     .stroke(Color.blue.opacity(0.35), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                     .frame(width: 260, height: 260)
                     .blur(radius: 1)
                     .opacity(0.5)
             }

             // --- COMPASS IN CENTER (subtle animation) ---
             CompassSymbol()
                 .frame(width: 80, height: 80)
                 .opacity(0.7)
                 .rotationEffect(.degrees(rotateCompass ? 360 : 0))
                 .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: rotateCompass)
                 .offset(y: -100)

             // --- LOADING TEXT + PROGRESS ---
             VStack(spacing: 18) {
                 ProgressView()
                     .scaleEffect(1.8)
                     .tint(.blue)

//                 Text("Preparing Navigation…")
//                     .font(.headline)
             }
             .offset(y: 90)
         }
         .onAppear {
             move1 = true
             move2 = true
             move3 = true
             rotateCompass = true
         }
     }
 }



struct RoutePathShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + 20, y: rect.maxY - 40))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY),
                       control: CGPoint(x: rect.minX + 40, y: rect.midY - 80))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - 30, y: rect.minY + 40),
                       control: CGPoint(x: rect.maxX - 60, y: rect.midY + 60))
        return p
    }
}


struct CompassSymbol: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 2)

            Image(systemName: "location.north.line.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.blue)
        }
    }
}





#Preview {
    LoadingScreen()
   
    
   
}
