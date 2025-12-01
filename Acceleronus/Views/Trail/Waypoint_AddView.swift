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
    
   //Paralax
    private let imageHeight: CGFloat = 300
    private let collapsedImageHeight: CGFloat = 75
    @StateObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    
   // @State var newID = UUID()
    init(
         dismiss: Binding<Bool>,
         editingMode: Bool = false,
         editingID: UUID = UUID(),
         wp_coordinates_: CLLocation = CLLocation(latitude: 0, longitude: 0),
         kilometer_: Double = 0) {
//        print("Add new Waypoint INIT")
        
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
                .padding(.bottom,15)

            
           WayPoint_CoordinatesSubView(wp_mileage: wp_mileage, wp_coordinates: wp_coordinates)
            .padding(.bottom,15)
                
            
            //Name and description
            VStack{
                TextField_WithTextLabel(title: "Name", inputText: $wp_name)
                TextFiled_Multiline(title: "Description", inputText: $wp_desc)
                    
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
            .frame(height: 600)
                    
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
        
        
                //CONTENT
                ScrollView(showsIndicators: false){
                    VStack{
                        Div1
                        Div2
                        
                    }.padding(.horizontal)                      
                     .offset(y: imageHeight - 16 )  //because is opened as a sheet, of ullscreencover need +32
                     .background(GeometryGetter(rect: $articleContent.frame))

                    
                    GeometryReader { geometry in
                        // 3
                        ZStack(alignment: .bottom) {
                            // Map()
//                            MapWithTrailSubView(trail: userModel.trailRecorded)
                           // TrailAnimationView()
                            Image("AddWayPoint2")
                                .resizable()
                                .scaledToFill()
                                .overlay{
//                                    CenteredWaypointOverlay(
//                                        waypoints: [
//                                            Waypoint(name: "Start"),
//                                            Waypoint(name: "Checkpoint 1"),
//                                            Waypoint(name: "River Crossing"),
//                                            Waypoint(name: "Summit")
//                                        ]
//                                    )
                                }
        
                              .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                              .blur(radius: self.getBlurRadiusForImage(geometry))
                              .clipped()
                              .background(GeometryGetter(rect: self.$headerImageRect))
                            
                            // 4
            //                                            Text("How to build a parallax scroll view")
            //                                                .font(.avenirNext(size: 17))
            //                                                .foregroundColor(.white)
            //                                                .offset(x: 0, y: self.getHeaderTitleOffset())
                        }
                        .clipped()
                        .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                    }.frame(height: imageHeight)
                     .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
                }
                .edgesIgnoringSafeArea(.all)
                .scrollDismissesKeyboard(.immediately)
              



        
                // CONTROL BUTTONS
                VStack {
              
                  HStack {
                      if(editingMode){
                          TrashButton.padding(.trailing,5)}
                      CancelButton
                    Spacer()
                      SaveButton
                  }
                  .padding()
                  .background(Color(UIColor.systemBackground).shadow(radius: 2))
                  
                }.padding(.bottom,2)

        
        

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
//        .onTapGesture {
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        }

        
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(10)
        

    }
    
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
        if offset < -sizeOffScreen {
            // Since we want 75 px fixed on the screen we get our offset of -225 or anything less than. Take the abs value of
            let imageOffset = abs(min(-sizeOffScreen, offset))
            
            // Now we can the amount of offset above our size off screen. So if we've scrolled -250px our size offscreen is -225px we offset our image by an additional 25 px to put it back at the amount needed to remain offscreen/amount on screen.
            return imageOffset - sizeOffScreen
        }
        
        // Image was pulled down
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    // at 0 offset our blur will be 0
    // at 300 offset our blur will be 6
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // (values will range from 0 - 1)
        
        return blur * 6 // Values will range from 0 - 6
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
    .environmentObject(DataStorage())
}
