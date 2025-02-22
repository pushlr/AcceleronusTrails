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
   // @EnvironmentObject var  photoStorage : PhotoStorageModel
    
   
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State var isShowing_PauseConfirmationDialog = false
    @State var isShowing_StopConfirmationDialog = false
    @State var isShowing_SaveTrailView = false 
    
    @State var AddWayPointSheet = false
    @State var selectActivitySheet = false
    
    @State var TrailsDetailedSheet_Detent : PresentationDetent = .fraction(0.35)
    
    @State var settingsSheet = false
    
    @State var inited = false
//    @State private var tabSelected: Tab = .navigator

    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
        _ = timer.connect()
    }
    
    func stopTimer() {
        timer.connect().cancel()
    }
    
    init() {
           UITabBar.appearance().isHidden = true
       }

    
    var body: some View {
        VStack(){
            TabView(selection: $userModel.tabSelected) {
                
                
                //MAP TAB
                VStack{
                    
                    ZStack(alignment: .bottom){
                        //map
                        MapView()
                            //trails in area loaded event
                            .onChange(of: userData.trailsInAreaisLoading, {
                                if(!userData.trailsInAreaisLoading) {userModel.DrawTrailsInArea(trails: &userData.trailsInArea) }
                                //need to select annotation?
                                if(userData.trailsInAreaNeedToSelect != nil ){
                                    if(userData.trailsInArea.first(where: {$0.id == userData.trailsInAreaNeedToSelect}) != nil){
                                         userModel.map.selectAnnotation(
                                           userData.trailsInArea.first(where: {$0.id == userData.trailsInAreaNeedToSelect})!.StartPin, animated: true)
                                        
                                        userData.trailsInAreaNeedToSelect = nil
                                    }
                                }
                            }
                            )
                        
                           //friend liveTracking event
                            .onChange(of: userData.liveTrackingFriendUpdated,{
                                if(userData.liveTrackingFriendUpdated.count>0){
                                    let workIndex = userData.liveTrackingFriendUpdated[0]
                                    if(workIndex < userData.friendsList.list.count){
                                        print("Drawing friend \((userData.friendsList.list[workIndex].userID))")
                                        userModel.DrawFriends(friend: &userData.friendsList.list[workIndex])
                                        userData.liveTrackingFriendUpdated.removeAll(where: {$0 == workIndex})// .remove(at: 0)
                                    } else{
                                        print("index \(workIndex) not exist in \(userData.friendsList.list.count)")
                                    }
                                }
                            }
                            )
                        


                        
                        if(userModel.recordingStatus == .isStarted){
                            Button(action: {
                                userModel.AddNewWayPoint()
                                //prepare storage
                                dataStorage.createStorageFor(userModel.tempWayPoint,trail: userModel.trailRecorded)
                                
                                AddWayPointSheet.toggle()
                            }) {
                                HStack{
                                    Image(systemName: "flag.fill")
                                    
                                    Text("Add WayPoint")
                                }.frame(width: 165, height: 45)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: 165, height: 45, alignment: .center)
                                    )
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom,5)
                        }//if is started END
                        
                        
                        //Control buttons on map
                        VStack{
                            if(userModel.recordingStatus == .isStarted){
                                //gps signal is updated in CLLocationManager delegate
                                SignalStrengthIndicator_SubView(strenght: SignalStrenght_to5Bar(signal: userModel.lastGPSStrenght))
                                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                    .frame(width: 30, height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: 45, height: 45, alignment: .center)
                                    ) 
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.bottom,25)
                            }
                            
                            
                            
                            //   if(userData.loadingTrails){
                            VStack{
                                Menu {
                                    
                                    //                                        Section{
                                    //                                            //trails list
                                    //                                            ForEach(userData.trailsLoaded){ item in
                                    //                                                Button(item.TrailName){}
                                    //                                            }
                                    //                                        }
                                    //                                        
                                    Section{
                                        if(userModel.recordingStatus == .isStarted){
                                            Text("Trails in area: -")
                                        }else{
                                            Text("Trails in area: \(userData.trailsInAreaCount)")
                                        }
                                            
                                        if(userModel.searchAreTooBig){
                                            Text("The selected map area is too large for the trails search!")
                                        }
                                    }
                                    
                                }
                            label:{
                                
                                ZStack{
                                    //disable TrailsInArea while recording
                                    if(userModel.recordingStatus == .isStarted){
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundStyle(.gray)
                                            .offset(x: -10, y: 0)
                                        Text("-")
                                            .offset(x: +12, y: 0)
                                            .foregroundStyle(.gray)
                                    }else{ // TrailsInArea info
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundStyle(userModel.searchAreTooBig ? .red : .blue)
                                            .offset(x: -10, y: 0)
                                        
                                        
                                        if(userData.trailsInAreaisLoading){
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                                .offset(x: +12, y: 0)
                                        }else{
                                            Text(String(userData.trailsInAreaCount))
                                                .offset(x: +12, y: 0)
                                            
                                        }
                                    }
                                }
                            }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white)
                                    .frame(width: 45, height: 45, alignment: .center)
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom,25)
                            .padding(.trailing,5)
                            
                            
                            
                            //Friends live tracking list
                            VStack{
                                
                                Menu {
                                    
                                    Section() {
                                        ForEach(userData.friendsList.list){item in
                                            if(item.recordingStatus == .isStarted){
                                                Button(item.DisplayName) {
                                                    userModel.map.region = MKCoordinateRegion(center:  item.trailRecorded.EndLocation,
                                                                                              latitudinalMeters: 500, longitudinalMeters: 500)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Section{Text("Active Tracking: \(userData.friendsList.friendsActiveTracking)")}
                                    
                                } label: {
                                    ZStack{
                                        Image(systemName: "person.wave.2.fill")
                                            .offset(x: -10, y: 0)
                                        
                                        
                                        Text(String(userData.friendsList.friendsActiveTracking))
                                            .offset(x: +12, y: 0)
                                        
                                    }
                                }
                                
                            } .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white)
                                    .frame(width: 45, height: 45, alignment: .center)
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing,5)
                            
                            
                            
                            
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom,17)
                        .padding(.trailing,15)
                        
                        
                        //                    if(userModel.recordingStatus != RecordingStatus.isStoped){
                        //                        VStack{
                        //                            //Friends live tracking list
                        //                            VStack{
                        //                                
                        //                                
                        //                                
                        //                           
                        //                                
                        //                                
                        //                                Menu{
                        //                                    
                        //                                      //  Text("asd")
                        //                                        Toggle(isOn: $userModel.trailRecordedSettings.activeTracking) {
                        //                                            Text("Active Tracking")
                        //                                        }
                        //                                    
                        //                                    ColorPicker("Line Color", selection:  $userModel.trailRecordedSettings.lineColor)
                        //                                       
                        //                                       
                        //                                    
                        //                                }
                        //                            label: { Image(systemName: "gear") }
                        //                                //.buttonStyle(ButtonDefault(ButtonColor: .pastelBlue,width: 50))
                        //                                // .frame(maxWidth: .infinity, alignment: .trailing)
                        //                                
                        //                                
                        //                            } .background(
                        //                                RoundedRectangle(cornerRadius: 10)
                        //                                    .foregroundColor(settingsSheet ? .white : .white)
                        //                                    .frame(width: 45, height: 45, alignment: .center)
                        //                                    .border(.gray)
                        //                            )
                        //                            .frame(maxWidth: .infinity, alignment: .leading)
                        //                            .padding(.leading,20)
                        //                            
                        //                        }
                        //                        .frame(maxHeight: .infinity, alignment: .bottom)
                        //                        .frame(maxWidth: .infinity, alignment: .trailing)
                        //                        .padding(.bottom,17)
                        //                        .padding(.trailing,15)
                        //                    }
                        
                        
                    }.ignoresSafeArea()
                    
                    
                    
                    
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
                                    Text(GetActivity(userModel.currentActivity).name.localized)
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
                                ButtonColor: (userModel.recordingStatus == RecordingStatus.isStarted) ? Color.brown:Color.green,width: UIScreen.main.bounds.width / 2
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
                                        Image(systemName: "stop.circle")
                                        Text("Stop")
                                    }
                                    
                                }
                                .buttonStyle(ButtonDefault(ButtonColor: Color.red,width: UIScreen.main.bounds.width / 4))
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
                  
                }.onReceive(timer){_ in
                    userModel.trailRecorded.TotalTime += 1
                    if(userModel.lastSpeed>0){
                        userModel.trailRecorded.MovingTime += 1
                    }
                }
                
                // Trail Detailed View shhet
                .sheet(isPresented: $userModel.annotationSelector.isTrailSelected,
                       onDismiss: {
                    // print("sheet dismiss");
                    // userModel.annotationSelector.isTrailSelected = false
                }
                )
                {
                    
                    TrailDetailedView(trail: $userData.trailsInArea[userModel.annotationSelector.selectedTrailID],
                                      detent: $TrailsDetailedSheet_Detent,
                                      isPinned: $userData.trailsInArea[userModel.annotationSelector.selectedTrailID].isPinned,
                                      sheetPresent: $userModel.annotationSelector.isTrailSelected
                    )
                    
                    
                    .presentationDetents([.fraction(0.35),.large],
                                         selection: $TrailsDetailedSheet_Detent)
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .large)
                    )
                    //                    .presentationCompactAdaptation(horizontal: .popover,
                    //                                                   vertical: .popover)
                    //  .presentationCornerRadius(10)
                }
                
                //Save Trail View
                .fullScreenCover(isPresented: $isShowing_SaveTrailView, content: {
                    SaveTrailView(trail: userModel.trailRecorded, showSaveTrailView: $isShowing_SaveTrailView)
                        .interactiveDismissDisabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                })
                
                
                //Select activity Sheet
                .sheet(isPresented: $selectActivitySheet, content: {
                    ActivitySelectorView(selectedActivity: $userModel.currentActivity,
                                         isPresented: $selectActivitySheet,
                                         selectedFlavor: GetActivity(userModel.currentActivity).category)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                })
                
                //Add WayPoint View
                .sheet(isPresented: $AddWayPointSheet, content: {
                    Waypoint_AddView(
                        dismiss: $AddWayPointSheet,
                        
                        wp_coordinates_: userModel.lastLocation,
                        kilometer_: userModel.trailRecorded.TrailDistance)
                })
                
                //Add/Edit/View WayPoint View
                .sheet(isPresented: $userModel.annotationSelector.isWayPointSelected,
                       onDismiss: {
                 //   print("sheet dismiss");
                   // userModel.annotationSelector.isWayPointSelected = false
                }, content: {
                    if(userModel.annotationSelector.selectedTrailID>=0){//existing trail
                        Waypoint_ViewView(
                            //                        trailUUID: userData.loadedTrails[userModel.annotationSelector.selectedTrailID].id, 
                            //  wayPoint: userData.trailsInArea[userModel.annotationSelector.selectedTrailID].WayPoints[userModel.annotationSelector.selectedWayPointID]
                            wayPoint: userData.trailsInArea[userModel.annotationSelector.selectedTrailID]
                                .WayPoints.first(where: {$0.id == userModel.annotationSelector.selectedWayPointID})!
                            
                        )
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .presentationBackgroundInteraction(
                            .enabled(upThrough: .medium)
                        )
                    }else{// current recorded trail
                        Waypoint_AddView(
                            dismiss: $userModel.annotationSelector.isWayPointSelected,
                            
                            editingMode: true,
                            editingID: userModel.annotationSelector.selectedWayPointID
                        )
                    }
                })
                
                
                  //.tabItem { Label("Navigator", systemImage: "globe.europe.africa.fill") }
                .tag(Tab.navigator)
                
                //ACCOUNT TAB
                UserAccountView()
                    .tag(Tab.person)
//                 .tabItem {
//                     Label("Account", systemImage: "person.crop.circle.fill")
//                
//                
//                 }
                
                
                
            }//tabview
          
            .onAppear{
                print("tabview onAppear")
                
                if userData.userID == "" { //call this code at first start
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
                    
                    inited = true
                }
                
            }
            
           
            
            
            VStack(spacing: 0) {
               // Spacer()
                CustomTabBar(selectedTab: $userModel.tabSelected)//.ignoresSafeArea()
                   // .frame(maxHeight: .infinity,alignment: .bottom)
            }
    
        }.ignoresSafeArea()
//        .onChange(of: userData.friendsList.list.count, {
//            print("friends list changed")
//            dataStorage.createStorageFor(userData.friendsList.list)
//           
//        })
//        
//        .onChange(of: userData.friendsSearchList.count, {
//            print("usersList list changed")
//            dataStorage.createStorageFor(userData.friendsSearchList)
//          
//        })
        
        
        
        

    }
}



#Preview {
    MainView()
    .environmentObject(UserModel())
    .environmentObject(UserData())
    .environmentObject(SignInViewModel())
    .environmentObject(DataStorage())
    
   
}


