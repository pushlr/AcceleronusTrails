//
//  UserAccountView2.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 28.11.2023.
//

import SwiftUI
import _MapKit_SwiftUI
import _PhotosUI_SwiftUI


//struct UserAccountView: View {
//    @EnvironmentObject var  auth : SignInViewModel
// //   @EnvironmentObject var userModel : UserModel
//    @EnvironmentObject var userData : UserData
//    //@EnvironmentObject var photoStorage : PhotoStorageModel
//    @EnvironmentObject var dataStorage: DataStorage
//    
//    init(){
//        print("INITED")
//    }
//    
//    var body: some View {
//        UserAccountView_2()
//            .environmentObject(auth)
//           // .environmentObject(userModel)
//            .environmentObject(userData)
//           // .environmentObject(photoStorage)
//            .environmentObject(dataStorage)
//    }
//}

struct UserAccountView: View {
    @EnvironmentObject var  auth : SignInViewModel
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var dataStorage: DataStorage

  
   // @State private var path = NavigationPath()
    
    @State var isShowingConfirmationDialog = false
    @State var showPhotoPicker = false
    @State var photoChanged = false
    @State var displayNameEditing  = false
    @State var deleteAccountView = false
    @State var testString = "acceleronus"
    @State var directorySize : UInt64 = 0
    init(){
//        print("User Account View : Inited!")
        // self.recordingStatus = recordingStatus
        
    }

    
    
    private func loadDisplayPhoto(){
        print("UserAccountView: Loading photo ")
        if(dataStorage.getStorage(userData.userID) != nil ){
            if(dataStorage.getStorage(userData.userID)!.items.count != 1){
                dataStorage.getStorage(userData.userID)!.removeAllExceptFirst(localyOnly: true)
                dataStorage.getStorage(userData.userID)!.addItem(DataItem(name:userData.DisplayPhoto))
                print("Display Photo: \(userData.DisplayPhoto)")
            }
        }
    }
    
    var SignOutButton: some View {
        Button(){
            isShowingConfirmationDialog.toggle()
        }label:{
            menuitemImage(systemName: "figure.walk.arrival", color: .pastelRed)
            Text("Sign Out")
                .foregroundColor(.red)
        }
        .confirmationDialog("Are you sure?",
                            isPresented: $isShowingConfirmationDialog,
                            titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                auth.SignOut()
                userData.SignOut()
                
            }
            Button("Cancel", role: .cancel) {}
        }
    }
  
    
    
    var PhotoPickerButton: some View {
        HStack{
            if(photoChanged){
                //Save button
                Button{
                    if(dataStorage.getStorage(userData.userID)!.items.count>0){
                        dataStorage.getStorage(userData.userID)!.removeAllExceptLast()
                        //dataStorage.getStorage(userData.userID)!.uploadToCloud()
                        dataStorage.uploadStorage(storageID: userData.userID)
                        userData.DisplayPhoto = dataStorage.getStorage(userData.userID)!.items[0].name
                        userData.db_SaveUserData()
                    }
                    photoChanged = false
                }
            label:
                {
                    Group{
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.pastelGreen)
                    }
                }
                
                
                //Cancel button
                Button{
                    photoChanged = false
                    self.loadDisplayPhoto()
                }
            label:
                {
                    Group{
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.pastelRed)
                    }
                }
                
                
                
            } else {
                
                
                Menu{
                    Button("Change profile photo"){showPhotoPicker = true}
                    Button("Change display name"){displayNameEditing = true}
                    Button("Delete Account",role: .destructive) {deleteAccountView = true}
                    
                }
            label:{
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
                
            }
            
            
            
        }
        .padding([.bottom,.trailing],10)
        
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
        NavigationStack() { //path: $userModel.navigationPath
            
            FancyScrollView(title: AnyView(
                                    ZStack{
                                        Text(userData.DisplayName)
                                            .font(.avenirNext(size: 17))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                        
                                        PhotoPickerButton
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .navigationTitle("Account")
                                ),
                            headerHeight: UIScreen.main.bounds.height / 3,
                            scrollUpHeaderBehavior: .parallax,
                            scrollDownHeaderBehavior: .offset,
                            header: {
                
                ZStack(alignment: .bottom) {
                    if(dataStorage.getStorage(userData.userID) != nil ){ // check for preview
                        UserPhotoView(storageID: userData.userID, imageName: dataStorage.getStorage(userData.userID)!.items.last?.name ?? "")
                            .scaledToFill()
                            .clipped()
                    }
                }
                .clipped()
                .onChange(of: userData.DisplayPhoto){
                    print("Display Phone Changed!")
                    loadDisplayPhoto()
                }
                
            }
                            
            ) {
                //CONTTENT START HERE
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        //photo and DisplayName stack
                        VStack(alignment: .leading) {
                            HStack {
                                
                                if(dataStorage.getStorage(userData.userID) != nil ){  //check for preview
                                    UserPhotoView(storageID: userData.userID, imageName: dataStorage.getStorage(userData.userID)!.items.last?.name ?? "")
                                        .scaledToFill()
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    
                                    
                                    EditableLabel(text: $userData.DisplayName, editing: $displayNameEditing)
                                        .onChange(of: userData.DisplayName, {
                                            print("Changing UserName")
                                            auth.ChangeDisplayName(DisplayName: userData.DisplayName)
                                            userData.db_SaveUserData()
                                        })
                                    
                                    
                                    if(userData.CreationDate != nil){
                                        Text("Joined from \(FormatTimeMonthYear(userData.CreationDate!))")
                                            .font(.avenirNext(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            if(userData.LastActivity != nil){
                                HStack{
//                                    Text("Last activity %@".localized(with:  (FormatTimeLastActivity(userData.LastActivity!))))
                                    Text("Last activity \(FormatTimeLastActivity(userData.LastActivity!))")
                                    .font(.avenirNextRegular(size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Text(" • ")
                                }
                                
                            }
                            
                        } .padding(.bottom,20)
                        
                        
                        
                        
                        //menu items
                        VStack(alignment: .leading){
                            
                            NavigationLink(destination: Account_MyTrails()) {
                                menuitemImage(systemName: "map.fill", color: Color.pastelBlue)
                                Text("My Trails")
                               // Text( userData.myTrailsCountIsLoading ? "Loading" : (userData.myTrailsCountLoadError ? "!" : "\(userData.myTrailsCount) >"))
                                Text("\(userData.myTrailsCount) >")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(.gray)
                                
                                
                            }
                            Divider()
                            
                            
//                            NavigationLink(destination: Account_MyTrails()) {
//                                menuitemImage(systemName: "heart.fill", color: Color.pastelOrange)
//                                Text("Favorites")
//                                Text("0 >")
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                    .foregroundColor(.gray)
//
//
//                            }
//                            Divider()
                            
                            
                            
                            NavigationLink(destination: Friends_List()) {
                                menuitemImage(systemName: "person.2.circle.fill", color: .pastelGreen)
                                
                                Text("Friends")
                                Text("\(userData.friendsList.list.count) >")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(.gray)
                            }
                            // .padding(3)
                            Divider()
                            
                            
                            
                            NavigationLink(destination: SettingsView()) {
                                menuitemImage(systemName: "gear", color: .pastelGray)
                                Text("Settings")
                                Text(">")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundColor(.gray)
                                
                                
                            }
                            // .padding(3)
                            Divider()
                            
                            
                            
//                            NavigationLink(destination: StorageView()) {
//                                menuitemImage(systemName: "macstudio.fill", color: .pastelGray)
//                                Text("Storage")
//                                Text(">")
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                    .foregroundColor(.gray)
//
//
//                            }
//                            // .padding(3)
//                            Divider()
                            
                            
                            
                            
                            SignOutButton
                            //.padding(3)
                            Divider()
                            
                            
                        }.padding(5)
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
         
                } //scroll view end
        
                .edgesIgnoringSafeArea(.all)
                .sheet(isPresented: $showPhotoPicker) {
                    PhotoPicker(storageID: userData.userID, imageSelected: $photoChanged)}
                .fullScreenCover(isPresented: $deleteAccountView){
                    DeleteAccountView(deleteAccountView: $deleteAccountView)
                }
           
                
                .onAppear{
                    self.loadDisplayPhoto()}
                
                
                //CONTENT END
                
            }
        }
       
    }}


class Utilities {

    @AppStorage("selectedAppearance") var selectedAppearance = 0
    var userInterfaceStyle: ColorScheme? = .light

    func overrideDisplayMode() {
        var userInterfaceStyle: UIUserInterfaceStyle

        if selectedAppearance == 2 {
            userInterfaceStyle = .dark
        } else if selectedAppearance == 1 {
            userInterfaceStyle = .light
        } else {
            userInterfaceStyle = .unspecified
        }
    
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}

struct AppearanceSelector: View {

    @AppStorage("selectedAppearance") var selectedAppearance = 0
    var utilities = Utilities()

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                selectedAppearance = 1
            }) {
                Text("Light")
            }
            Spacer()
            Button(action: {
                selectedAppearance = 2
            }) {
                Text("Dark")
            }
            Spacer()
            Button(action: {
                selectedAppearance = 0
            }) {
                Text("System")
            }
            Spacer()
        }
        .onChange(of: selectedAppearance, perform: { value in
            utilities.overrideDisplayMode()
        })
    }
}




struct UserAccountView_Preview : PreviewProvider {
    
//    var userData = UserData()
//    var userModel = UserModel()
//    @State var detent = PresentationDetent.large
   
    static var previews: some View {
   // var body: some View{
        @State var userData = UserData()
        @ObservedObject var dataStorage = DataStorage()
        let userModel = UserModel()
        @State var detent = PresentationDetent.large
        @State var isPinned = false
        @State var sheetPresent = true


        
        UserAccountView()//.colorScheme(.dark)
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
