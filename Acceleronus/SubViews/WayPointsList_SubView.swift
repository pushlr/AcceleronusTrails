//
//  WayPointsList_SubView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 11.11.2023.
//

import SwiftUI
import CoreLocation

struct WayPointsList_SubView: View {
  //  let trailID : UUID
    @Binding var wayPoints : [WayPoint]
    var editMode = false
   // var photoStorage : PhotoStorageModel
 //   @EnvironmentObject var photoStorage : PhotoStorageModel
  //  @EnvironmentObject var dataStorage : DataStorage
    @State private var selectedWPIdx_forDelete : Int = -1
    @State private var selectedWPIdx_forView : Int = -1
    @State private var wp_ViewSheet = false
    @State private var wp_DelConfirm = false
    
    init(wayPoints: Binding<[WayPoint]>, editMode: Bool = false) {
//        print("WayPointsList_SubView initing")
      //  self.trailID = trailID
        self._wayPoints = wayPoints
        self.editMode = editMode
        
  
//        self.photoStorage = PhotoStorageModel(workDir: trailID.uuidString)
//        //prepare waypoint images
//        if(!self.wayPoints.isEmpty){
//            for i in 0..<self.wayPoints.count{
//                self.photoStorage.addItems(self.wayPoints[i].images)
//            }
//        }
    }
    
    var body: some View {
        if(wayPoints.isEmpty){
            Text("no WayPoints added").font(.footnote).italic()
            
        }else{
            VStack{
                ForEach(Array(wayPoints.enumerated()),id: \.offset){ index,item in
                    HStack(spacing: 0){
                        
                        
                        //view button
                    Button{
                            self.selectedWPIdx_forView = index
                        }
                    label:{
                        //image
                        if(item.images.isEmpty){
                            Image(systemName: "photo")
                                .frame(width: 40,height: 40)
                                .padding(.trailing,10)
                                .foregroundColor(.gray)
                        }else{
                            
                         //   GridItemView(size: 40, item: photoStorage.getItem(item.images[0].name) ?? PhotoItem(name: "unknown"))
                            GridItemView(size: 40, storageid: item.id.uuidString, itemIndex: 0)
                            .cornerRadius(5.0)
                            .aspectRatio(1, contentMode: .fit)
                        
                            
                        }
                        
                        VStack(alignment: .leading, spacing:0){
                            Text(item.name)
                                .foregroundStyle(.blue)
                            //   .fontWeight(.bold)
                            Text(item.time.formatted())
                                .font(.footnote)
                                .foregroundStyle(.black)
                        }
                    }.frame(maxWidth: .infinity,alignment: .leading)
                           
                        
                        if(editMode){
                            Menu {
                                //remove button
                                Button(role: .destructive){
                                    self.selectedWPIdx_forDelete = index
                                }
                            label:{
                                Label("Remove",systemImage: "trash")
                                
                                
                            }
                            }
                        label: {
                            Text("...")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        }
                    }
                    
                    
                    if(index<wayPoints.count-1){
                        Divider()
                    }
                    
                }
                .padding([.leading,.trailing],40)
                .onChange(of: selectedWPIdx_forView, initial: false, { oldState, newState in if(newState>=0) {self.wp_ViewSheet = true;print("index for view changed")}})
                .onChange(of: selectedWPIdx_forDelete, initial: false, {oldState, newState in if(newState>=0) {self.wp_DelConfirm = true;}})
            }
            .onAppear{
                //create dataStorage for each waypoint
//                for i in 0...wayPoints.count-1 {
//                    if wayPoints[i].imagesStorageID == nil {
//                        wayPoints[i].imagesStorageID = dataStorage.createStorage(workDir: trailID.uuidString)
//                        dataStorage.getStorage(wayPoints[i].imagesStorageID!)!.addItems(wayPoints[i].images)
//                    }
//                }
            }
            //delete waypoint confirmation dialog
            .confirmationDialog("Are you sure?",
                                isPresented: $wp_DelConfirm,
                                titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    wayPoints.remove(at: selectedWPIdx_forDelete)
                    selectedWPIdx_forDelete = -1
                }
                Button("Cancel", role: .cancel) { selectedWPIdx_forDelete = -1}
                
            }
            
            //View Waypoint
            .sheet(isPresented: $wp_ViewSheet,onDismiss: {print("dismiss sheet \(wp_ViewSheet)");selectedWPIdx_forView = -1},
                   content: {
                                    
                                    Waypoint_ViewView(                                       
                                        wayPoint: wayPoints[selectedWPIdx_forView]//selectedWaypoint!
                                    )
                                    .presentationDetents([.large])
                                    .presentationDragIndicator(.visible)
                
                                    
                                })
            
        }
    }
    
}

#Preview {
    WayPointsList_SubView(//trailID: UUID(),
                          wayPoints: .constant([WayPoint(name: "Test6",desc: "desc6", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937))]),
                          editMode: true
                          
                         )
}
