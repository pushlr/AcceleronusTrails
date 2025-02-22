//
//  SettingsView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 13.12.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var userModel : UserModel
    
    
    
    var appVersion: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
            return "Unknown"
        }
    }
    
    
    var body: some View {
        
        
        
      //  VStack{
            List{
               
                Section(header: Text("Trail Recording")) {
                    Toggle(isOn: $userModel.trailRecordedSettings.activeTracking) {
                        Text("Active Tracking")
                        Text("Allow my friends to track me")
                        
                    }.toggleStyle(.switch)
                       
                    
                    ColorPicker(selection:  $userModel.trailRecordedSettings.lineColor){
                        Text("Line Color")
                       }
                }
                
                
                Section(header: Text("Memory Usage")) {
                    NavigationLink(destination: StorageView()) {
                        Text("Storage")
                    }
                }
                
                Section(header: Text("Contact")){
                    Button{
                        let subject = "Acceleronus Trails: Question"
                        let body = "Hello".localized + ",\n"
                        guard let emailURL = URL(string: "mailto:pushlr@icloud.com?subject=\(subject)&body=\(body)") else { return }
                        UIApplication.shared.open(emailURL)
                    } label:{
                        Text("Contact Us")
                       
                    }
               
                }
                
                
                Text("App Version: " + appVersion)
                    .font(.footnote)
                    .foregroundStyle(.pastelGray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                
                
                
                
            }
            .listStyle(.inset)
           // .scrollContentBackground(.hidden)
           
            .navigationTitle("Settings")
     //
        
            .onChange(of: userModel.trailRecordedSettings.activeTracking){
                userData.saveTrailSettingsUserDefaults(trailSettings: userModel.trailRecordedSettings)
                if(!userModel.trailRecordedSettings.activeTracking){
                    print("Stop Tracking from Settings")
                    userData.db_storeTrailRecorded(trail: userModel.trailRecorded, recordingStatus: .isStoped) //stop live tracking
                }
            }
        
            .onChange(of: userModel.trailRecordedSettings.lineColor){
               userData.saveTrailSettingsUserDefaults(trailSettings: userModel.trailRecordedSettings)}
    }
}




#Preview {
    SettingsView()
        .environmentObject(UserData())
        .environmentObject(UserModel())
    
}
