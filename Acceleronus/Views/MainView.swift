//
//  MainView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 26.09.2023.
//

import Foundation
import SwiftUI
import MapKit



struct MainView: View {
  
    @EnvironmentObject var  auth : SignInViewModel
    @EnvironmentObject var  userModel : UserModel
    @EnvironmentObject var  userData : UserData
    @EnvironmentObject var  dataStorage : DataStorage
    @Environment(\.locale) var locale
    @Environment(\.scenePhase)  var scenePhase

    
    @State private var initialized : Bool
    
    init() {
           print("MainView: INIT")
           UITabBar.appearance().isHidden = true
           initialized = false
       }
    


    @MainActor
    private func initialize() async {
        
        print("MainView: Initializing")
        let start = Date()
    
        //get changes from auth
        userData.DisplayName = auth.getDisplayName()
        userData.userID = auth.getUserID()
        userData.email = auth.getEmail()
        userData.CreationDate = auth.getCreationDate()
        userData.LastSignInDate = auth.getLastActivityDate()
        userData.LastActivity = Date()
        
        //save to db if not exist
        userData.db_SaveUserDataBaseInfo()
        
        //userData listener
        userData.db_ListenToUserData()
                
        //my trails load, at first max 10 items
        userData.db_GetMyTrails()
        
        //check UserDefaults
        if(userData.loadTrailUserDefaults(trail: &userModel.trailRecorded)){
            userModel.recordingStatus = .isPaused
            dataStorage.loadTrailImages(trail: userModel.trailRecorded)
            
            //set lastlocation to last trail location
            userModel.lastLocation = CLLocation(latitude: userModel.trailRecorded.coordinateRecorded.last?.latitude ?? 0,
                                                longitude: userModel.trailRecorded.coordinateRecorded.last?.longitude ?? 0)
            
            //draw polyline
            userModel.drawPolyline(trail: &userModel.trailRecorded)
            
            //draw waypoints
            if(!userModel.trailRecorded.WayPoints.isEmpty){
                
                for i in 0...userModel.trailRecorded.WayPoints.count - 1{
                    userModel.drawWayPoint(wayPoint: &userModel.trailRecorded.WayPoints[i])
                }
            }
            
            
            //add Start place
            if(userModel.trailRecorded.coordinateRecorded.count>=1){
                userModel.drawStartLocation()
                //center map to lastlocation
                userModel.centerMap_toLastLocation()
            }
            
        }
        
        //load local settings
        userData.loadTrailRecordingSettings(trailSettings: &userModel.trailRecordedSettings)
        
        
        //create userPhoto dataStorage
        dataStorage.createStorageFor(userData)
        
        
        //get currentActivity
        userModel.currentActivity = ActivityType(rawValue: UserDefaults.standard.string(forKey: "currentActivity") ?? "") ?? .HIKING
        
        //continue unfinished works
        //   UserDefaults.standard.set(0, forKey: "UploadManager_WorksCount")
        dataStorage.uploadManager.doWork()
        

        //set language
        userData.getLanguageFromUserDefaults(app_language: &userModel.language)
        if userModel.language.isEmpty{
            let preferred = Locale.preferredLanguages.first   // "ru-UA"
            let code = String(preferred?.prefix(2) ?? "en")   // "ru"
            
            if let appLang = AppLanguage(rawValue: code) {
                userModel.language = appLang.rawValue
            } else {
                userModel.language = AppLanguage.en.rawValue
            }
        }
        
        //end time
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 1.0 - elapsed)
        if remaining > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
        }
        
        
        withAnimation(.easeInOut(duration: 0.4)) {
            initialized = true
        }
            
        
    }
    
    var body: some View {
        
        
        
        VStack(){
            
            
                if initialized {
                    //CONTENT
                    ZStack {
                        VStack {
                            MainNavigatorView()
                            NavigatorControlPanel()
                        }
                            .opacity(userModel.tabSelected == .navigator ? 1 : 0)
                            .animation(.easeInOut(duration: 0.1), value: userModel.tabSelected)
                        
                        UserAccountView()
                            .opacity(userModel.tabSelected == .person ? 1 : 0)
                            .animation(.easeInOut(duration: 0.1), value: userModel.tabSelected)

                        
                      }

                  
                    //MENU BAR
                    CustomTabBar(selectedTab: $userModel.tabSelected)
                   
                    
                } else {
                    //LOADING SCREEN
                    LoadingScreen()

                }
                
                
               
           
    
           
            

    
        }.ignoresSafeArea()
         .task {if !initialized {await initialize() }}
         .onChange(of: scenePhase){ oldPhase,newPhase in
              if newPhase == .active {
                  print("Send last activity to server")
                  if initialized{
                      userData.LastActivity = Date()
                      userData.db_UpdateLastActivity()
                  }
             }
         }

         .environment(\.locale, Locale(identifier: userModel.language))

              

    }
}



#Preview {
    MainView()
    .environmentObject(UserModel())
    .environmentObject(UserData())
    .environmentObject(SignInViewModel())
    .environmentObject(DataStorage())
    
    
   
}


