//
//  TrailInfoView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 19.10.2023.
//

import SwiftUI

struct TrailInfoView: View {
    var trail : Trail
 
    var body: some View {
        VStack{
            
            HStack{
                
                VStack(alignment: .center){
                    Text("Distance")
                        .font(.caption)
                    Text(trail.TrailDistanceFormatted)
                        .font(.headline)
                    
                }
                
                .padding()
                
               
                VStack(alignment: .center){
                    Text("Total Time")
                        .font(.caption)
                    Text(trail.TotalTimeFormatted)
                        .font(.headline)
                    
                    
                }
                .padding()
                
                VStack(alignment: .center){
                    Text("Moving Time")
                        .font(.caption)
                    Text(trail.MovingTimeFormatted)
                        .font(.headline)
                    
                }
                .padding()
                
                
                
                
                
            }.padding(1)
            
            HStack{
                
                VStack{
                    Text("Max Altitude")
                        .font(.caption)
                    Text(String(format:"%.2f m",trail.AltitudeMax))
                        .font(.headline)
                    
                }
                .padding()
                
                VStack{
                    Text("Max Speed")
                        .font(.caption)
                    Text(speedToString(trail.SpeedMax))
                        .font(.headline)
                    
                }
                .padding()
                
            }.padding(1)
            
        }
        
    }
}

#Preview {
    TrailInfoView(trail: Trail()).environmentObject(UserModel())
}
