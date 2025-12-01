//
//  NavigatorControlPanel.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 24.11.2025.
//

import SwiftUI

struct NavigatorControlPanel: View {
    @EnvironmentObject var  userModel : UserModel
    @EnvironmentObject var  userData : UserData
    @EnvironmentObject var  dataStorage : DataStorage
    
    @State var selectActivitySheet = false
    @State var isShowing_PauseConfirmationDialog = false
    @State var isShowing_StopConfirmationDialog = false
    @State var isShowing_SaveTrailView = false
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
        _ = timer.connect()
    }
    
    func stopTimer() {
        timer.connect().cancel()
    }
    
    
    var body: some View {
        if(userModel.recordingStatus != RecordingStatus.isStoped){
            TabView() {
                TrailRecordedStatus_1().tabItem {}
                TrailRecordedStatus_2().tabItem {}
                
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .frame(height: 140)
            
        }
        
        
        
        //Start recording button
        VStack{
            if(userModel.recordingStatus == RecordingStatus.isStoped){
                VStack{
                    //SELECT ACTIVITY
                    Button(){
                        withAnimation{
                            selectActivitySheet.toggle()
                        }
                    }label:{
                        VStack(spacing: 0){
                            Image(GetActivity(userModel.currentActivity).image)
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text(GetActivity(userModel.currentActivity).name)
                        }
                    }
                    //START BUTTON
                    Button(){
                        withAnimation{
                            
                            userModel.StartRecording()
                            dataStorage.createStorageFor(userModel.trailRecorded)
                            startTimer()
                        }
                        
                        
                    }label:{
                        HStack{
                            Image(systemName: "record.circle")
                            Text("Start Recording")
                        }}
                    
                    .buttonStyle(
                        ButtonDefault(
                            ButtonColor: Color.green,
                            width: UIScreen.main.bounds.width - 50
                        ))
                    
                    
                }
            }else{
                
                
                //Start/pause buttons
                HStack{
                    //select activity button
                    
                    Button(){
                        withAnimation{
                            switch (userModel.recordingStatus){
                            case RecordingStatus.isStarted:
                                isShowing_PauseConfirmationDialog = true
                            case RecordingStatus.isPaused:
                                userModel.ResumeRecording()
                                startTimer()
                            default : break
                            }}
                        
                    }
                    label:{
                        HStack{
                            
                            switch (userModel.recordingStatus){
                            case RecordingStatus.isStarted:
                                Image(systemName: "pause")
                                Text("Pause")
                                
                            case RecordingStatus.isPaused:
                                Image(systemName: "playpause")
                                Text("Resume")
                            case RecordingStatus.isStoped:
                                Image(systemName: "record.circle")
                                Text("Start Recording")
                                
                            }
                            
                        }
                    }
                    
                    .buttonStyle(
                        ButtonDefault(
                            ButtonColor: (userModel.recordingStatus == RecordingStatus.isStarted) ? Color.brown:Color.green//,width: UIScreen.main.bounds.width / 3
                        ))
                    
                    .confirmationDialog("Are you sure?",
                                        isPresented: $isShowing_PauseConfirmationDialog,
                                        titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            userModel.PauseRecording()
                            stopTimer()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                    
                    
                    
                    
                    //
                    
                    //stop button
                    if(userModel.recordingStatus != RecordingStatus.isStoped){
                        Button(){
                            isShowing_StopConfirmationDialog = true
                            
                            
                        }label: {
                            HStack{
                                Image(systemName: "flag.pattern.checkered")
                                Text("Finish")
                            }
                            
                        }
                        .buttonStyle(ButtonDefault(ButtonColor: Color.red///,width: UIScreen.main.bounds.width / 3
                        ))
                        .confirmationDialog("Are you sure?",
                                            isPresented: $isShowing_StopConfirmationDialog,
                                            titleVisibility: .visible) {
                            Button("Yes", role: .destructive) {
                                userModel.StopRecording()
                                userData.db_storeTrailRecorded(trail: userModel.trailRecorded, recordingStatus: .isStoped) //stop live tracking
                                stopTimer()
                                
                                //save only if coordinates recorded is 2 or more
                                if(userModel.trailRecorded.coordinateRecorded.count > 1){
                                    isShowing_SaveTrailView=true
                                } else{
                                    UserDefaults.standard.set(false,forKey: "trailNotSaved") //dont read trail from backup at next start
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        
                        
                    }
                    
                    
                }
            }
        } .padding(.bottom,10) //60 manu bar + 10
        
        //Select activity Sheet
        .sheet(isPresented: $selectActivitySheet, content: {
            ActivitySelectorView(selectedActivity: $userModel.currentActivity,
                                 isPresented: $selectActivitySheet,
                                 selectedFlavor: GetActivity(userModel.currentActivity).category)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        })
        
        //Save Trail View
        .fullScreenCover(isPresented: $isShowing_SaveTrailView, content: {
            SaveTrailView(trail: userModel.trailRecorded, showSaveTrailView: $isShowing_SaveTrailView)
                .interactiveDismissDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            
        })
        
        
        
//        //Select activity Sheet
//        .sheet(isPresented: $selectActivitySheet, content: {
//            ActivitySelectorView(selectedActivity: $userModel.currentActivity,
//                                 isPresented: $selectActivitySheet,
//                                 selectedFlavor: GetActivity(userModel.currentActivity).category)
//            .presentationDetents([.large])
//            .presentationDragIndicator(.visible)
//        })
        
        
        
        .onReceive(timer){_ in
            userModel.trailRecorded.TotalTime += 1
            if(userModel.lastSpeed>0){
                userModel.trailRecorded.MovingTime += 1
            }
        }
        
        

    }
}

#Preview {
    NavigatorControlPanel()
        .environmentObject(UserModel())
        .environmentObject(UserData())
        .environmentObject(SignInViewModel())
        .environmentObject(DataStorage())
        
}
