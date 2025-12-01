//
//  MainNavigatorView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 24.11.2025.
//

import SwiftUICore
import SwiftUI
import MapKit



struct MainNavigatorView: View {
    @EnvironmentObject var  userModel : UserModel
    @EnvironmentObject var  userData : UserData
    @EnvironmentObject var  dataStorage : DataStorage
    
    
  
    @State var AddWayPointSheet = false


    @State private var trailSheetDismis = false
    @State private var wayPointSheetDismis = false
    @State private var trailColorChanged = false
    @State private var selectedTrailUUID : UUID? = nil
    
    @State var TrailsDetailedSheet_Detent : PresentationDetent = .fraction(0.35)

    var body: some View {
        VStack{
            
                
                ZStack(alignment: .top){
                    
                    //map
                    MapView(trailSheetDismissed: $trailSheetDismis,
                            wayPointSheetDismissed: $wayPointSheetDismis,
                            trailColorChanged: $trailColorChanged,
                            selectedTrailUUID: $selectedTrailUUID
                    )
                    
                    //search bar overlay
                    .overlay(alignment: .top) {
                        
                        VStack {
                            
                            AutocompleteMapSearchView()
                                .frame(width: 300)
                                .cornerRadius(12)
                            
                            if(userModel.recordingStatus == .isStarted){
                                GPSSignalWarningView(isVisible: $userModel.weakGPSSignal)
                            }
                            
                            
                        }
                        .padding(.top, 55)
                        .padding(.horizontal)
                    }
                    
                    // add new WayPoint overlay
                    .overlay(alignment: .bottom){
                        if(userModel.recordingStatus == .isStarted){
                            Button(action: {
                                userModel.AddNewWayPoint()
                                dataStorage.createStorageFor(userModel.tempWayPoint,trail: userModel.trailRecorded)
                                AddWayPointSheet.toggle()
                            }) {
                                HStack{
                                    Image(systemName: "flag.fill")
                                    Text("Add WayPoint")
                                }.frame(width: 175, height: 45)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: 165, height: 45, alignment: .center)
                                    )
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom,5)
                            
                            
                            
                            
                        }
                    }
                    
                    
                    .overlay(alignment: .bottomTrailing) {
                        
                        VStack(alignment: .trailing){
                            
                            //                                    SignalStrengthIndicator_SubView(strenght: SignalStrenght_to5Bar(signal: userModel.lastGPSStrenght))
                            //                                        .frame(width: 30, height: 20)
                            //                                        .background(
                            //                                            RoundedRectangle(cornerRadius: 10)
                            //                                                .foregroundColor(.systemGray6)
                            //                                                .frame(width: 45, height: 45)
                            //                                        )
                            
                            ActiveTrackingButton()
                            
                            // TRAILS IN AREA
                            MapMenuControl(
                                iconName: "mappin.and.ellipse",
                                labelText: userModel.recordingStatus == .isStarted ? "-" : "\(userData.trailsInAreaCount)",
                                foregroundStyle: userModel.recordingStatus == .isStarted ? .gray : (userModel.searchAreTooBig ? .red : .blue),
                                isLoading: userData.trailsInAreaisLoading
                            ) {

                                Section() {
                                    ForEach(userData.trailsInArea.indices, id: \.self) { index in
                                            let item = userData.trailsInArea[index]
                                            Button(item.TrailName) {
                                                userModel.map.region = MKCoordinateRegion(center:  item.StartLocation,
                                                                                          latitudinalMeters: 2000, longitudinalMeters: 2000)
                                                selectedTrailUUID = item.id
                                                
                                            }
                                        
                                        


                                    }
                                }

                                
                                Section {
                                    if userModel.recordingStatus == .isStarted {
                                        Text("Trails in area: -")
                                    } else {
                                        Text("Trails in area: \(userData.trailsInAreaCount)")
                                    }
                                    
                                    if userModel.searchAreTooBig {
                                        Text("The selected map area is too large for the trails search!")
                                    }
                                }
                            }
                            
                            
                            // ACTIVE SHARING
                            MapMenuControl(
                                iconName: "person.2.wave.2.fill",
                                labelText: "\(userData.friendsList.friendsActiveTracking)",
                                foregroundStyle: .blue,
                                isLoading: false
                            ) {
                                Section() {
                                    ForEach(userData.friendsList.list){item in
                                        if(item.recordingStatus == .isStarted){
                                            Button(item.DisplayName) {
                                                userModel.map.region = MKCoordinateRegion(center:  item.trailRecorded.EndLocation,
                                                                                          latitudinalMeters: 2000, longitudinalMeters: 2000)
                                            }
                                        }
                                    }
                                }
                                
                                Section{Text("Active Tracking: \(userData.friendsList.friendsActiveTracking)")}
                                
         

                                
                                
                            }
                            
                            
                           
 
                                  

                        
                            
                            
                        }
                        .padding(.bottom,10)
                        .padding(.trailing,5)
                    }
                    
                    
                    
                    //trails in area loaded event
                    .onChange(of: userData.trailsInAreaisLoading, {
                        if(!userData.trailsInAreaisLoading) {userModel.DrawTrailsInArea(trails: &userData.trailsOnMap) }
                        //need to select annotation?
                        if(userData.trailsInAreaNeedToSelect != nil ){
                            if(userData.trailsOnMap.first(where: {$0.id == userData.trailsInAreaNeedToSelect}) != nil){
                                userModel.map.selectAnnotation(
                                    userData.trailsOnMap.first(where: {$0.id == userData.trailsInAreaNeedToSelect})!.StartPin, animated: true)
                                
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
                    
                    
                    
                    
                    
                    
                }.ignoresSafeArea()
                

                
            }
            .ignoresSafeArea(.keyboard)

            
            
            .sheet(isPresented: $userModel.annotationSelector.iscurrTrailWayPointSelected,
                   onDismiss: {
                
            }
            )
            {
                Waypoint_AddView(
                    dismiss: $userModel.annotationSelector.iscurrTrailWayPointSelected,
                    
                    editingMode: true,
                    editingID: userModel.annotationSelector.selectedCurrTrailWayPointID
                )
                
            }
            
            // Trail Detailed View shhet
            .sheet(isPresented: $userModel.annotationSelector.isTrailSelected,
                   onDismiss: {
                trailSheetDismis = true
            }
            )
            {
                if (userModel.annotationSelector.isWayPointSelected){ // show waitpoint in the save sheet
                    
                    Waypoint_ViewView(
                        wayPointSheetDismissed: $wayPointSheetDismis,
                        //                        trailUUID: userData.loadedTrails[userModel.annotationSelector.selectedTrailID].id,
                        //  wayPoint: userData.trailsInArea[userModel.annotationSelector.selectedTrailID].WayPoints[userModel.annotationSelector.selectedWayPointID]
                        wayPoint: userData.trailsOnMap[userModel.annotationSelector.selectedTrailID]
                            .WayPoints.first(where: {$0.id == userModel.annotationSelector.selectedWayPointID})!
                        
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .medium)
                    )
                    
                    
                }else { // show trail
                    TrailDetailedView(trail: $userData.trailsOnMap[userModel.annotationSelector.selectedTrailID],
                                      detent: $TrailsDetailedSheet_Detent,
                                      isPinned: $userData.trailsOnMap[userModel.annotationSelector.selectedTrailID].isPinned,
                                      sheetPresent: $userModel.annotationSelector.isTrailSelected,
                                      trailColorChanged: $trailColorChanged
                    )
                    
                    
                    .presentationDetents([.fraction(0.35),.large],
                                         selection: $TrailsDetailedSheet_Detent)
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .large)
                    )
                    //                    .presentationCompactAdaptation(horizontal: .popover,
                    //                                                   vertical: .popover)
                    //  .presentationCornerRadius(10)
                }
            }
            
            


            
            //Add WayPoint View
            .sheet(isPresented: $AddWayPointSheet, content: {
                Waypoint_AddView(
                    dismiss: $AddWayPointSheet,
                    
                    wp_coordinates_: userModel.lastLocation,
                    kilometer_: userModel.trailRecorded.TrailDistance)
                
                .interactiveDismissDisabled(true)
            })
            
            
            
            
            
            
        }}



#Preview {
    MainNavigatorView()
        .environmentObject(UserModel())
        .environmentObject(UserData())
        .environmentObject(SignInViewModel())
        .environmentObject(DataStorage())
        
}

