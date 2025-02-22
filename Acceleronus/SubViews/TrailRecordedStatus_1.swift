//
//  TrailRecordedStatus_1.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 30.10.2023.
//

import SwiftUI

struct TrailRecordedStatus_1: View {
    @EnvironmentObject var  userModel : UserModel
    
    var body: some View {
        VStack(spacing:0){
            //LINE 1
            VStack(alignment: .center){
                Text("Distance")
                    .font(.caption)
                Text(userModel.trailRecorded.TrailDistanceFormatted)
                    .font(.largeTitle)
                
            }
            
            //LINE 2
            HStack(alignment: .center,spacing: 0){
                VStack(alignment: .center){
                    Text("Total Time")
                        .font(.caption)
                    Text(userModel.trailRecorded.TotalTimeFormatted)
                        .font(.headline)
                    
                    
                }.padding()
                .frame(width: UIScreen.main.bounds.width / 3)
                
                
                VStack(alignment: .center){
                    Text("Moving Time")
                        .font(.caption)
                    Text(userModel.trailRecorded.MovingTimeFormatted)
                    //Text("1 day 12 hours 54 minutes")
                        .font(.headline)
                    
                }.padding()
                .frame(width: UIScreen.main.bounds.width / 3)
                
                
                VStack(alignment: .center){
                    Text("Altitude")
                        .font(.caption)
                    Text(String(format: "%.2f", userModel.lastLocation.altitude))
                        .font(.headline)
                    
                }.padding()
                .frame(width: UIScreen.main.bounds.width / 3)
                
            }
            
        }
        
        
    }
}

#Preview {
    TrailRecordedStatus_1()
        .environmentObject(UserModel())
}
