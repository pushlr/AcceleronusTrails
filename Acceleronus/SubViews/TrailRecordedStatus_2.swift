//
//  TrailRecordedStatus_2.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 30.10.2023.
//

import SwiftUI

struct TrailRecordedStatus_2: View {
    @EnvironmentObject var  userModel : UserModel
    
    var body: some View {
        VStack(spacing:0){
            //LINE 1
            VStack(alignment: .center){
                Text("Speed")
                    .font(.caption)
                Text(speedToString(userModel.lastSpeed))
                    .font(.largeTitle)
                
            }
            
            //LINE 2
            HStack(){
                VStack{
                    Text("GPS Signal: ") .font(.caption)
                    Text(SignalStrenghtText(signal: userModel.lastGPSStrenght))
                        .font(.headline)
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width / 3)
                
                VStack(alignment: .center){
                    Text("Distance")
                        .font(.caption)
                    Text(userModel.trailRecorded.TrailDistanceFormatted)
                        .font(.headline)
                    
                }.padding()
                    .frame(width: UIScreen.main.bounds.width / 3)
                

                
                VStack(alignment: .center){
                    Text("Max Speed")
                        .font(.caption)
                    Text(speedToString(userModel.trailRecorded.SpeedMax))
                        .font(.headline)
                    
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width / 3)
                
                
            
            }
            
            
        }
    }
}

#Preview {
    TrailRecordedStatus_2()
        .environmentObject(UserModel())
}
