//
//  UserAccountView2.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 28.11.2023.
//

import SwiftUI
import _MapKit_SwiftUI
import _PhotosUI_SwiftUI

struct FriendAccountView: View {
    @EnvironmentObject var auth : SignInViewModel
    @EnvironmentObject var dataStorage: DataStorage
    @EnvironmentObject var userData: UserData
    let friendIndex : Int
    
    
    
    
    private func loadDisplayPhoto(){
        if(friendIndex<userData.friendsList.list.count){
            if(dataStorage.getStorage(userData.friendsList.list[friendIndex].userID) != nil ){
                if(dataStorage.getStorage(userData.friendsList.list[friendIndex].userID)!.items.count != 1){
                    dataStorage.getStorage(userData.friendsList.list[friendIndex].userID)!.removeAllExceptFirst(localyOnly: true)
                    dataStorage.getStorage(userData.friendsList.list[friendIndex].userID)!.addItem(DataItem(name:userData.friendsList.list[friendIndex].DisplayPhoto))
                    print("Display Photo: \(userData.friendsList.list[friendIndex].DisplayPhoto)")
                }
            }
        }
    }
    
    
    
    
    
    struct menuitemImage: View{
        let systemName : String
        let color : Color
        
        var body: some View {
            Image(uiImage:
                    UIImage(systemName: systemName)!
                .imageWithColor(tintColor: .white)
                .reclangledImage(width: 4, color: UIColor(color))!
            )
        }
    }
    
    
    
    var body: some View {
        //  NavigationView{
        if(friendIndex<userData.friendsList.list.count){
            FancyScrollView(title: AnyView(
                
                ZStack{
                    Text(userData.friendsList.list[friendIndex].DisplayName)
                        .font(.avenirNext(size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                    
                } //.navigationTitle("\(userData.friendsList.list[friendIndex].DisplayName)")
                
            ),
                            headerHeight: UIScreen.main.bounds.height / 3,
                            scrollUpHeaderBehavior: .parallax,
                            scrollDownHeaderBehavior: .offset,
                            hiddenNavigationBar: false,
                            //  hiddenNavigationBar : false,
                            header: {
                
                ZStack(alignment: .bottom) {
                    if(dataStorage.getStorage(userData.friendsList.list[friendIndex].userID) != nil ){ // check for preview
                        UserPhotoView(storageID: userData.friendsList.list[friendIndex].userID,
                                      imageName: dataStorage.getStorage(userData.friendsList.list[friendIndex].userID)!.items.last?.name ?? "")
                        .scaledToFill()
                        .clipped()
                    }
                }
                .clipped()
            }
                            
            )
            
            //VStack
            {
                //CONTTENT START HERE
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        //photo and DisplayName stack
                        VStack(alignment: .leading) {
                            HStack {
                                
                                if(dataStorage.getStorage(userData.friendsList.list[friendIndex].userID) != nil ){  //check for preview
                                    UserPhotoView(storageID: userData.friendsList.list[friendIndex].userID,
                                                  imageName: dataStorage.getStorage(userData.friendsList.list[friendIndex].userID)!.items.last?.name ?? "")
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(userData.friendsList.list[friendIndex].DisplayName).font(.avenirNext(size: 17))
                                    
                                    
                                    if(userData.friendsList.list[friendIndex].CreationDate != nil){
                                        Text("Joined from \(FormatTimeMonthYear(userData.friendsList.list[friendIndex].CreationDate!))")
                                            .font(.avenirNext(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                }
                            }
                            
                            if(userData.friendsList.list[friendIndex].LastActivity != nil){
                                HStack{
                                    Text("Last activity \(FormatTimeLastActivity(userData.friendsList.list[friendIndex].LastActivity!))")
                                        .font(.avenirNextRegular(size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Text(" • ")
                                }
                                
                            }
                            
                        } .padding(.bottom,20)
                        
                        
                        
                        if (userData.friendsList.list[friendIndex].isLoading){
                            ProgressView().frame(maxWidth: .infinity)
                        }else{
                            //trails and friends count
                            //                        HStack(alignment: .center){
                            //                            VStack(alignment: .center){
                            //                                Text("Trails").font(.caption)
                            //                                Text("\(userData.friendsList.list[friendIndex].myTrailsCount)").font(.headline)
                            //                            }
                            //                            .padding()
                            //
                            //
                            //                            VStack(alignment: .center){
                            //                                Text("Friends").font(.caption)
                            //                                Text("\(userData.friendsList.list[friendIndex].myFriendsCount)").font(.headline)
                            //                            }
                            //                            .padding()
                            //                        }.frame(maxWidth: .infinity)
                            //
                            
                            
                            NavigationLink(destination: Account_FriendTrails(friendIndex: friendIndex)) {
                                menuitemImage(systemName: "map.fill", color: Color.pastelBlue)
                                Text("Trails")
                                Text("\(userData.friendsList.list[friendIndex].myTrailsCount) >")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(.gray)
                                
                                
                            }
                            
                        }
                        
                        //Draw friend trails
                        // Account_FriendTrails(friendIndex: friendIndex)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    
                } //scroll view end
                .edgesIgnoringSafeArea(.all)
                .onAppear{
                    self.loadDisplayPhoto()
                    if(!userData.friendsList.list[friendIndex].dataLoaded){
                        userData.db_GetFriendInfo(friendIndex: friendIndex)
                    }
                    
                }
                
                //CONTENT END
                
            }
            //                }
            //  .listStyle(.plain)
            //   .navigationTitle("\(userData.friendsList.list[friendIndex].DisplayName)")
            
        
    } else {
        Text("Deleted User")
    }
    
    }
}






struct FriendAccountView_Preview : PreviewProvider {
    
   
    static var previews: some View {
        @State var userData = UserData()
        @ObservedObject var dataStorage = DataStorage()
        let userModel = UserModel()
        @State var detent = PresentationDetent.large
        @State var isPinned = false
        @State var sheetPresent = true


        
        FriendAccountView(friendIndex: 0)//.colorScheme(.dark)
            .environmentObject(userData)
                .environmentObject(userModel)
                .environmentObject(SignInViewModel())
                .environmentObject(dataStorage)
                .onAppear{
                    userData.userID = "randomstring"
                    dataStorage.createStorageFor(userData)
                    
                }
     
    }
}
