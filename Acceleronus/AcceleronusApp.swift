//
//  AcceleronusApp.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 26.09.2023.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct AcceleronusApp: App{
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    init(){
//        userData.DisplayName = auth.getDisplayName()
//        userData.userID = auth.getUserID()
//        
//        userData.db_SaveUserData()
//        userData.db_ListenToUserData()
//        userData.db_ListenToTrails()
        
    }
    
    var body: some Scene {
        WindowGroup {
            var auth = SignInViewModel()
            var userModel = UserModel()
            var userData = UserData()
            var photoStorage = PhotoStorageModel(workDir: "/")
            var dataStorage = DataStorage()
            
            StartView()
                .environmentObject(auth)
                .environmentObject(userData)
                .environmentObject(userModel)
                .environmentObject(photoStorage)
                .environmentObject(dataStorage)
            
                .navigationViewStyle(.stack)
               
                
                
        }
    }
}
