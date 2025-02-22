//
//  Account_FriendTrails.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 25.01.2024.
//

import SwiftUI
import _MapKit_SwiftUI

struct Account_FriendTrails: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
    let friendIndex : Int

 
    

    
    var body: some View {
        if(friendIndex<userData.friendsList.list.count){
            
            VStack{
                if(userData.friendsList.list[friendIndex].dataLoaded && userData.friendsList.list[friendIndex].myTrailsCount==0){
                    ContentUnavailableView(label: {Label("No trails recorded",systemImage: "tray.fill").font(.callout)},
                                           description: {Text("Empty for now, but not for long!").font(.footnote)}
                    ).frame(maxHeight: .infinity, alignment: .center)
                    
                } else {
                    
                    ScrollView {
                        
                        
                        
                        //                HStack{
                        //                    if (userData.friendsList.list[friendIndex].myTrailsIsLoading && userData.friendsList.list[friendIndex].mytrails.count == 0){
                        //                        ProgressView()
                        //                            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                        //                            .padding(.leading,5)
                        //                    }
                        //                }.frame(maxWidth: .infinity,alignment: .leading)
                        //                    .padding(5)
                        //
                        
                        LazyVStack{
                            ForEach(userData.friendsList.list[friendIndex].mytrails) { item in
                                FriendTrailCard(item: item)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Rectangle().fill(Color.white))
                                    .cornerRadius(10)
                                    .shadow(color: .gray, radius: 3, x: 0, y: 0)
                                    .padding(5)
                                    .onAppear{
                                        print("FriendTrailCard appear: \(item.TrailName)")
                                        
                                        if (item.id == userData.friendsList.list[friendIndex].mytrails.last!.id && !userData.friendsList.list[friendIndex].myTrailsIsLoading) {
                                            userData.db_getFriendTrails(friendIndex: friendIndex)
                                        }
                                        
                                        
                                        
                                    }
                            }
                            
                            if userData.friendsList.list[friendIndex].mytrails.count < userData.friendsList.list[friendIndex].myTrailsCount{
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black)).padding(25)}
                            
                        }
                        
                    }
                    
                    .onAppear{
                        //load first trails
                        if(userData.friendsList.list[friendIndex].mytrails.count == 0){
                            userData.db_getFriendTrails(friendIndex: friendIndex)
                        }
                        // loaded in MainView
                        //  userData.db_GetMyTrails()
                    }
                    
                }
                
                
                
            }.listStyle(.plain)
                .navigationTitle("\(userData.friendsList.list[friendIndex].DisplayName)'s Trails (\(userData.friendsList.list[friendIndex].myTrailsCount))")
            
            
        }
        
    }
}




struct FriendTrailCard: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
    @State var item : Trail
    
    
    @State var isShowingConfirmationDialog = false
    @State var trailForDelete : UUID = UUID()
    
    var body: some View {
        
        VStack(){
            
            //Activity type and trail name
            HStack{
                Image(GetActivity(item.activityType).image)
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack{
                    Text(item.TrailName)
                      //  .foregroundColor(.black)
                        .font(.title2)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                    HStack{
                        
                        ZStack(alignment: .leading){
                            Text(GetActivity(item.activityType).name.localized)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.footnote)
                        }
                        
                        Text((item.StartTime.formatted()))
                            .font(.caption)
                            .frame(maxWidth: .infinity
                                   
                                   
                                   
                                   , alignment: .trailing)
                    }
                }
                
                
            }
            
            Divider().padding(.bottom,5)

            
            //Distance and time
            HStack{
                VStack(alignment: .center){
                    Text("Distance")
                        .font(.caption)
                    Text(item.TrailDistanceFormatted)
                        .font(.headline)
                }//.border(.red)
                .padding(.leading,10)
                
                
                
                Spacer()
                
                VStack(alignment: .center){
                    Text("Total Time")
                        .font(.caption)
                    Text(item.TotalTimeFormatted)
                        .font(.headline)
                }//.border(.blue)
                .padding(.trailing,10)
                
            }
            
            
            
//
//             MapWithTrailSubView(trail: item)
//             .frame(height: 120)
//
            Divider().padding(.bottom,10)
            
            //Control buttons
            HStack{
                
                NavigationLink(destination:
                                // TrailInfoView(trail: item)
                               
                               TrailDetailedView(trail: .constant(item),
                                                 detent: .constant(.large),
                                                 isPinned: .constant(false),
                                                 sheetPresent: .constant(false),
                                                 withTopControlButtons: false,
                                                 withBackground: false,
                                                 withMap: true,
                                                 withBottomControlButtons: true
                                                )
                               
                               
                               
                )
                {
                    Label("Details",systemImage: "ellipsis.rectangle")
                    
                }.padding(.trailing,10)
                
//                NavigationLink(destination: EditTrailView(trail: item)) {
//                    Label("Edit",systemImage: "square.and.pencil")
//                    
//                }.padding(.trailing,10)
//                 .disabled(true)
//                
//                
//                Button{print("deleteClicked");trailForDelete = item.id; }
//            label:{Label("Remove",systemImage: "trash.slash").foregroundColor(.red)}
//                    .confirmationDialog("Are you sure?",
//                                        isPresented: $isShowingConfirmationDialog,
//                                        titleVisibility: .visible) {
//                        Button("Remove Trail", role: .destructive) {
//                            //mytrails list
//                            if(userData.mytrails.first(where: {$0.id == trailForDelete}) != nil){
//                                dataStorage.removeTrailImages(trail: userData.mytrails.first(where: {$0.id == trailForDelete})!)
//                            }
//                            //search list, when searching trail new list is createad, check it
//                            if(userData.mytrailsSearch.first(where: {$0.id == trailForDelete}) != nil){
//                                dataStorage.removeTrailImages(trail: userData.mytrailsSearch.first(where: {$0.id == trailForDelete})!)
//                            }
//                            userData.db_RemoveTrail(trailID: trailForDelete);
//                            userData.removeTrail(trailID: trailForDelete)
//                           
//                        }
//                        Button("Cancel", role: .cancel) {}
//                    }
//                                        .padding(.trailing,10)
                
                
            }
            
        }
        .onChange(of: trailForDelete, {print("on change"); isShowingConfirmationDialog.toggle() })
//        .border(.red)
        
    }
}
#Preview {
    Account_FriendTrails(friendIndex: 0)
        .environmentObject(UserData())
        .environmentObject(DataStorage())
}
