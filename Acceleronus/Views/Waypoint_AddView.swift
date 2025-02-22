//
//  Waypoint_AddView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 23.10.2023.
//

import SwiftUI
import MapKit

struct Waypoint_AddView: View {
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
    
  
    @Binding var sheetPresent : Bool
    
    //
    var editingMode : Bool = false
    var editingID : UUID = UUID()
    @State var wp_coordinates : CLLocation //= CLLocation(latitude: 0, longitude: 0)
    @State var wp_mileage : Double //= 0
    
    //input fields
    @State var wp_name = ""
    @State var wp_desc = ""
    @State var trashConfirmation = false
    @State var cancelConfirmation = false
    
   
   // @State var newID = UUID()
    init(
         dismiss: Binding<Bool>,
         editingMode: Bool = false,
         editingID: UUID = UUID(),
         wp_coordinates_: CLLocation = CLLocation(latitude: 0, longitude: 0),
         kilometer_: Double = 0) {
        print("Add new Waypoint INIT")
        
        self._sheetPresent = dismiss
        self._wp_coordinates = State(initialValue: wp_coordinates_)
        self._wp_mileage =  State(initialValue: kilometer_)
             
        self.editingMode = editingMode
        self.editingID = editingID
        
    }
    
    var Div1: some View{
       
        VStack{
            
            Text(editingMode ? "Edit WayPoint" : "Add new WayPoint")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                .padding(.bottom, 15)
            
           WayPoint_CoordinatesSubView(wp_mileage: wp_mileage, wp_coordinates: wp_coordinates)
            .padding(.bottom,15)
                
            
            //Name and description
            VStack{
                TextField_WithTextLabel(title: "Name".localized, inputText: $wp_name)
                TextFiled_Multiline(title: "Description".localized, inputText: $wp_desc)
                    
            }
            
        }.onAppear{
            if(editingMode){
                if let wp = userModel.getWayPoint(id: editingID) {
                    self.wp_coordinates = wp.coordonates
                    wp_name = wp.name
                    wp_desc = wp.desc
                }
                
            }
        }
        
    }
    
    var Div2: some View{
        
        GridView(storageID: editingMode ? editingID.uuidString : userModel.tempWayPoint.id.uuidString, EditingMode: true)
                    
    }
    
    var TrashButton: some View{
        
        Button {trashConfirmation.toggle()}
        label: {Image(systemName: "trash.circle")}
        .buttonStyle(ButtonDefault(ButtonColor: Color.red,
                                   width: 60, height: 40))
        .confirmationDialog("Are you sure?",
                            isPresented: $trashConfirmation,
                            titleVisibility: .visible) {
            Button("Yes", role: .destructive) {
                //remove annotation and remove waypoint from collection
                print("removing waypoint at index \(editingID)")
                userModel.removeWayPoint(wayPoint: userModel.getWayPoint(id: editingID))
                userModel.trailRecorded.WayPoints.removeAll(where: {$0.id == editingID})
                sheetPresent = false
                
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            //Text("Waypoint and photos will be lost and cannot be restored!")
        }
        
    }
    
    var CancelButton: some View{
        //cancel button
        Button {sheetPresent = false} label: {Text("Cancel")}
        .buttonStyle(ButtonDefault(ButtonColor: Color.black, width: 100,height: 40))
//        .confirmationDialog("Are you sure?",
//                            isPresented: $cancelConfirmation,
//                            titleVisibility: .visible) {
//            Button("Yes", role: .destructive) { sheetPresent = false }
//            // Button("No", role: .destructive) { }
//            Button("Cancel", role: .cancel) {}
//        }
        
    }
    
    var SaveButton: some View{

        Button {
            if(editingMode){
                if let index = userModel.getWayPointIndex(id: editingID) {
                    userModel.trailRecorded.WayPoints[index].name = wp_name
                    userModel.trailRecorded.WayPoints[index].desc = wp_desc
                    userModel.trailRecorded.WayPoints[index].images = dataStorage.getStorage(editingID.uuidString)?.items ?? []
                   
                    userModel.removeWayPoint(wayPoint: userModel.trailRecorded.WayPoints[index])
                    userModel.drawWayPoint(wayPoint: &userModel.trailRecorded.WayPoints[index])
                }
            }else{
                //insert new waypoint
//                userModel.trailRecorded.WayPoints.insert(
//                    WayPoint(name: wp_name,
//                             desc: wp_desc,
//                             coordonates: wp_coordinates,
//                             mileage: wp_mileage,
//                             images: []),//photoStorage.items),
//                    at: userModel.trailRecorded.WayPoints.count
//                )
                userModel.tempWayPoint.name = wp_name
                userModel.tempWayPoint.desc = wp_desc
                userModel.tempWayPoint.coordonates = wp_coordinates
                userModel.tempWayPoint.mileage = wp_mileage
                userModel.tempWayPoint.images = dataStorage.getStorage(userModel.tempWayPoint.id)?.items ?? []
                
                userModel.trailRecorded.WayPoints.append(userModel.tempWayPoint)
                
                //save to UserDefaults for backup
                userData.saveTrailUserDefaults(trail: userModel.trailRecorded)
                
                //draw waypoint to map
                userModel.drawWayPoint(
                    wayPoint: &userModel.trailRecorded.WayPoints[userModel.trailRecorded.WayPoints.count-1])
            }
            
            sheetPresent = false
            
        } label: {
            Text(editingMode ? "Save" : "Add")
     
        }
    
        .buttonStyle(
            ButtonDefault(
                Disabled: wp_name.isEmpty,
                ButtonColor: Color.green,
                width: 150,
                height: 40
            ))
        .disabled(wp_name.isEmpty)
       
        
        
    }
        
        
    
    
    
    var body: some View {
        
        NavigationView {
      //      if userModel.getWayPoint(id: editingID) != nil {  //check for deleting
                ScrollView(showsIndicators: false){
                    Div1
                    Div2
                }
                
                .toolbar {
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack(){
                            if(editingMode){
                                TrashButton.padding(.trailing,5)}
                            CancelButton
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        SaveButton
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                }
   //         }//if
        }
        
//        .background{
//           
//                Image(chooseRandomImage()).resizable()
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(minWidth: 0,maxWidth: .infinity)
//                    .ignoresSafeArea()
//                    .opacity(0.5)
//            
//        }
        .onAppear{
            print("Add new waypoint appear!")
//            userModel.tempWayPoint = WayPoint()
//            userModel.dataStorage.createStorage(workDir: userModel.tempWayPoint!.id.uuidString, id: userModel.tempWayPoint!.id)
           // photoStorage.ChangeWorkDir(workDir: trailID)
           // photoStorage.items.removeAll()
            //prepare storage
            if(editingMode){
                //dataStorage.getStorage(userModel.trailRecorded.WayPoints[editingID].id)?.addItems(userModel.trailRecorded.WayPoints[editingID].images)
            }
            
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(10)
        

    }
    
}

#Preview {

    Waypoint_AddView(
        dismiss: .constant(true),
       
        editingMode: false,
        wp_coordinates_: (CLLocation()),
        kilometer_: 10
    )
    .environmentObject(UserModel())
}
