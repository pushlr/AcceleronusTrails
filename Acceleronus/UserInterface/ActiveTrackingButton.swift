//
//  ActiveTrackingButton.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 25.11.2025.
//
import SwiftUI
import SwiftUICore



struct ActiveTrackingButton: View {
    @EnvironmentObject var  userModel : UserModel
    @EnvironmentObject var  userData : UserData
    
    @State private var showLabel = false

    var body: some View {
        Button(action: {
           
            if !showLabel{
                showLabel = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showLabel = false
                    }
                }
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "person.wave.2.fill")
                    .font(.system(size: 16, weight: .medium))

                if showLabel {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Active Tracking")
                            .font(.system(size: 15, weight: .semibold))
                      
                        
                        Toggle(isOn: $userModel.trailRecordedSettings.activeTracking){}
                        .scaleEffect(0.8)
                        .padding(.vertical, -4)
                        .onChange(of: userModel.trailRecordedSettings.activeTracking){oldValue, newValue in
                            // Toggle the tracking setting
                            userModel.trailRecordedSettings.activeTracking = newValue
                            userData.saveTrailSettingsUserDefaults(trailSettings: userModel.trailRecordedSettings)
                
                            if !userModel.trailRecordedSettings.activeTracking {
                                print("Stop Tracking from Settings")
                                userData.db_storeTrailRecorded(
                                    trail: userModel.trailRecorded,
                                    recordingStatus: .isStoped
                                )
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showLabel = false
                                    
                                }
                            }
                        }
                        
                    }
                    .fixedSize()                   
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
            .foregroundStyle(userModel.trailRecordedSettings.activeTracking ? .green : .gray)
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
        }
    
    }
}

#Preview {
    ActiveTrackingButton()
        .environmentObject(UserModel())
        .environmentObject(UserData())
        .environmentObject(SignInViewModel())
        .environmentObject(DataStorage())
        
}
