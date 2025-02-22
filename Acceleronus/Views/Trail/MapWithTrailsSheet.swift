//
//  MapWithTrailsSheet.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 26.01.2024.
//

import SwiftUI

struct MapWithTrailsSheet: View {
    let trail : Trail
    @Binding var isPresented : Bool
    
    var closeButton: some View {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }
        
    }
    
    var body: some View {
        VStack(spacing:0) {
            ZStack{
                HStack{
                  //  Image(systemName: "globe.europe.africa.fill").foregroundStyle(.black)
                    Text("Map Preview")
                        .foregroundStyle(.black)
                }
                
                closeButton
                    .frame(maxWidth: .infinity,alignment: .trailing)
                    .padding(.trailing,10)
            }.frame(height: 20)
               
             .padding(10)
            
            MapWithTrailSubView(trail: trail)
           
        }
    }
}

#Preview {
    MapWithTrailsSheet(trail: Trail(), isPresented: .constant(true))
}
