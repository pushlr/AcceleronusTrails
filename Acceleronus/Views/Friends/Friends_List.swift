//
//  Friends_List.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 14.11.2023.
//

import SwiftUI


struct Friends_List: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
       
    @State private var searchText = ""
    @State var lastScheduledSearch: Timer?
    @State var showLoadingAnimation = false
    @State private var searchisPresented = false
    
    var searchResults: [FriendInfo] {
            if searchText.isEmpty {
                return userData.friendsList.list
            } else {
                return userData.friendsSearchList
            }
        }
    
    var body: some View {
        

            
            ScrollView {
                
                if(searchText.isEmpty){
                    //FRIENDS LIST
                    // TextCaptionWithDivider(text: "Friends list").padding([.leading,.trailing],5)
                    
                    if(searchResults.isEmpty){
                        ContentUnavailableView(label: {Label("No friends added",systemImage: "person.fill.badge.plus").font(.callout)},
                                               description: {Text("Solo for now, friend-filled trails ahead.").font(.footnote)}
                        )
                        //.frame(maxHeight: .infinity, alignment: .center)
                        .padding(.top,UIScreen.main.bounds.height / 4)
                    }
                    ForEach(searchResults) { user in
                        UserCard(user: $userData.friendsList.list[userData.friendsList.list.firstIndex(where: {$0.id == user.id})!])
                    }
                    
                }else{
                    //SEARCH LIST
                    // TextCaptionWithDivider(text: "Global Search").padding([.leading,.trailing],5)
                    HStack{
                        if (userData.friendsSearchIsLoading || showLoadingAnimation ){
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                .padding(.leading,5)
                        }else{
                            if(!searchText.isEmpty){
                                Text("Found \(userData.friendsSearchCount) users")
                                    .font(.caption)
                            }
                        }
                    }.frame(maxWidth: .infinity,alignment: .leading)
                        .padding(5)
                    
                    //    if searchResults.isEmpty && !userData.friendsSearchIsLoading {Text("empty").font(.footnote)}
                    
                    
                    ForEach(searchResults) { user in
                        UserCard(user: $userData.friendsSearchList[userData.friendsSearchList.firstIndex(where: {$0.id == user.id})!])
                            .onAppear{
                                if (user.id == userData.friendsSearchList.last?.id && !userData.friendsSearchIsLoading) {
                                    print("Loading next users")
                                    userData.db_SearchUser(contain: searchText)
                                }
                            }
                    }
                    
                    //bottom loading animation
                    if userData.friendsSearchList.count < userData.friendsSearchCount && userData.friendsSearchIsLoading{
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black)).padding(25)}
                    
                    
                    
                }
                
                
                
            }
            .listStyle(.plain)
            .navigationTitle("Friends (\(userData.friendsList.list.count))")
            
            
            .searchable(text: $searchText,isPresented: $searchisPresented, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText, {
                
                if(!searchText.isEmpty ){
                    showLoadingAnimation = true
                    lastScheduledSearch?.invalidate() //cancel timer
                    
                    //run timer after 1 second
                    lastScheduledSearch = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block:
                                                                {_ in
                        
                        userData.friendsSearchCursor = nil
                        withAnimation{
                            userData.friendsSearchList.removeAll()
                            userData.db_SearchUser(contain: searchText)
                        }
                        showLoadingAnimation = false
                        
                    })
                }
                
            })
            
            .onChange(of: searchisPresented){ //cancel button clicked
                print("isPresented: \(searchisPresented)");
                if !searchisPresented {
                    searchText = ""
                    userData.friendsSearchList.removeAll()
                }
            }
            
            
            .onChange(of: userData.friendsList.list.count,{
                self.loadImages()
            })
            
            .onChange(of: userData.friendsSearchList.count,{
                self.loadImages()
            })
            
            
            .onAppear{
                self.loadImages()
            }
            
     
        
    }
    
    
    private func loadImages(){ //loading avatars for friends list

        print("FriendsList loadImages")
        if(userData.friendsList.list.count>0){
            for i in 0...userData.friendsList.list.count-1{
                let item = userData.friendsList.list[i]
                
                print("Adding \(item.DisplayPhoto) for user \(item.DisplayName)")
                if(dataStorage.getStorage(item.userID) == nil ){
                    print("Storage not yet created!")
                    dataStorage.createStorageFor(item)
                    
                }
                dataStorage.getStorage(item.userID)?.addItem(DataItem(name: item.DisplayPhoto))
            }
        }
        
        if(userData.friendsSearchList.count>0){
            for i in 0...userData.friendsSearchList.count-1{
                let item = userData.friendsSearchList[i]
                
                print("Adding \(item.DisplayPhoto) for user \(item.DisplayName)")
                if(dataStorage.getStorage(item.userID) == nil ){
                    print("Storage not yet created!")
                    dataStorage.createStorageFor(item)
                    
                }
                
                dataStorage.getStorage(item.userID)?.addItem(DataItem(name: item.DisplayPhoto))
            }
        }

      }
    
    
}










struct UserCard: View {
    @EnvironmentObject var userData : UserData
  //  @EnvironmentObject var photoStorage: PhotoStorageModel
    @EnvironmentObject var dataStorage : UserData
    
    @Binding var user : FriendInfo
    
    @State var isShowingDeleteConfirmationDialog = false
    @State var isShowingUnsendConfirmationDialog = false
    
    
    
    var body: some View{
        VStack{
            Divider()
            HStack{

                if(user.friendStatus == .requestAccepted && userData.friendsList.list.firstIndex(where: {$0.userID == user.userID}) != nil){
                    NavigationLink(destination:FriendAccountView(friendIndex: userData.friendsList.list.firstIndex(where: {$0.userID == user.userID})!))
                    {
                        UserPhotoView(storageID: user.userID, imageName: user.DisplayPhoto)
                            .scaledToFill()
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }}else{
                        UserPhotoView(storageID: user.userID, imageName: user.DisplayPhoto)
                            .scaledToFill()
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                

                HStack{
                    
                    if(user.friendStatus == .requestAccepted && userData.friendsList.list.firstIndex(where: {$0.userID == user.userID}) != nil){
                        NavigationLink(destination:FriendAccountView(friendIndex: userData.friendsList.list.firstIndex(where: {$0.userID == user.userID})!))
                        {
                            Text(user.DisplayName)
                                .foregroundColor(.black)
                            
                        }.padding(.trailing,10)
                    }else
                    {
                        Text(user.DisplayName)
                            .foregroundColor(.black)
                    }
                   
                    
                    if user.recordingStatus == .isStarted {
                        Image(systemName: "record.circle").foregroundStyle(.pastelRed).padding(.leading,5)
                            .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                        //Text("Recording trail" /*+ GetActivity(user.trailRecorded.activityType).name*/ ).font(.footnote)
                    }
                }.frame(maxWidth: .infinity,alignment: .leading)
                if(user.friendStatus == .requestNotSent){
                    Button(){
                        user.friendStatus = .requestSent
                        // userData.friendsList.append(user)
                        userData.db_sendFriendRequest(friend: user)
                        
                    }
                label:{Text("Add to Friends")}
                        .buttonStyle(ButtonDefault(ButtonColor: Color.primary,width: 220,height: 40))
                }
                
                if(user.friendStatus == .requestAccepted){
                    
                    Menu {
                        //user Details
//                        Button(){print(user.id)}
//                        label:{Text("User details")}
//                            .buttonStyle(ButtonDefault(ButtonColor: Color.gray,width: 220,height: 40))
//                            .disabled(true)
                        
                        //remove button
                        Button(role: .destructive){
                            //userData.db_deleteFriend(friend: user)
                            isShowingDeleteConfirmationDialog = true
                        }
                    label:{Label("Remove from Friends list",systemImage: "")}
                    }
                    label: {
                        Text("...")
                            .font(.title)
                            .foregroundColor(.gray)
                            
                    }
                    .padding(.trailing,5)
                    .confirmationDialog("Are you sure?",
                                        isPresented: $isShowingDeleteConfirmationDialog,
                                        titleVisibility: .visible) {
                        Button("Yes",role: .destructive) {
                            userData.db_deleteFriend(friend: user)
                            user.friendStatus = .requestNotSent
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                    
                    
                    
                    
                    
                }
                
                if(user.friendStatus == .requestSent){
                    Button(){
                        isShowingUnsendConfirmationDialog = true
                    }
                        label:{Text("Unsend request")}
                        .buttonStyle(ButtonDefault(ButtonColor: Color.brown,width: 220,height: 40))
                        .confirmationDialog("Are you sure?",
                                            isPresented: $isShowingUnsendConfirmationDialog,
                                            titleVisibility: .visible) {
                            Button("Yes",role: .destructive) {
                                userData.db_deleteFriend(friend: user)
                                user.friendStatus = .requestNotSent
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    
                }
                
                
                if(user.friendStatus == .requestObtained){
                    Button(){ userData.db_acceptFriendRequest(friend: user)}
                    label:{Text("Accept Friend Request")}
                    .buttonStyle(ButtonDefault(ButtonColor: Color.green,width: 220,height: 40))
                }
                
                
                
            }.padding(5)
            
        }
        
        
        
        
    }

    
    
}




#Preview {
    Friends_List()
        .environmentObject(UserData())
        .environmentObject(DataStorage())
}
