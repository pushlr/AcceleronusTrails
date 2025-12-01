//
//  TrailDetailedView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 16.10.2023.
//

import SwiftUI
import MapKit


struct TrailDetailedView: View {
  @EnvironmentObject var userModel : UserModel
  @EnvironmentObject var userData : UserData
 // @StateObject var photoStorage : PhotoStorageModel = PhotoStorageModel(workDir: "/")
  @EnvironmentObject var dataStorage : DataStorage
  @Binding var  trail : Trail
    
  @Binding var isPinned : Bool
  @Binding var detent : PresentationDetent
  @Binding var sheetPresent : Bool
    @Binding var trailColorChanged : Bool
  
    
    let withTopControlButtons : Bool
    let withBackground : Bool
    let withBottomControlButtons : Bool
    let withMap : Bool
  
  
  @State private var deviceOrientation = UIDevice.current.orientation
  @State private var showColorSelector = false
  @State var showBigMap = false
     
    init(trail: Binding<Trail>, 
         detent: Binding<PresentationDetent>,
         isPinned: Binding<Bool>,
         sheetPresent: Binding<Bool>,
         trailColorChanged: Binding<Bool>,
         withTopControlButtons: Bool = true,
         withBackground: Bool = true,
         withMap: Bool = false,
         withBottomControlButtons: Bool = false) {
        //print("init TrailDetailedView")
        self._detent = detent
        self._isPinned = isPinned
        self._sheetPresent = sheetPresent
        self._trailColorChanged = trailColorChanged
        self._trail = trail
        self.withTopControlButtons = withTopControlButtons
        self.withBackground = withBackground
        self.withMap = withMap
        self.withBottomControlButtons = withBottomControlButtons

        self.showColorSelector = false
        
    }

    
    func setTrailColor(_ color: Color) {
        if let index = userData.trailsOnMap.firstIndex(where: { $0.id == trail.id }) {
            userData.trailsOnMap[index].color = UIColor(color)

           print("set collor changed")
           trailColorChanged = true
        }
    }
    
    var body: some View{
        
        VStack(){
            
            HStack{
  
            VStack(alignment: .leading, spacing:0){
                
                HStack{
                   
                    
                    Text(trail.TrailName)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                   
                    if(withTopControlButtons){
                        //change color
                        Button {
                            withAnimation {
                                showColorSelector.toggle()
                            }
                        } label: {
                            Image(systemName: "paintpalette")
                                .font(.system(size: 18))
                        }
                        .padding(.trailing, 5)
                        .frame(maxWidth: 30, alignment: .trailing)
                        
                        
                        //pin unpin
                        Button{withAnimation{isPinned.toggle()}}
                    label:{
                        if(!isPinned){Image(systemName: "pin").rotationEffect(.degrees(40))}
                        else{Image(systemName: "pin.fill")}
                    }.padding(.trailing,5)
                            .frame(maxWidth: 30, alignment: .trailing)
                        
                        if(deviceOrientation.isLandscape || UIDevice.isIPad){
                            Button{sheetPresent = false}
                        label:{Image(systemName: "xmark")}
                        }
                        
                    }
                }

                
                HStack{
                  //  ZStack(alignment: .leading){
                    
                        Text(GetActivity(trail.activityType).name)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .font(.footnote)
                ///    }
                    ///    
                    
                    if trail.confidentiality == .Private{
                        HStack(spacing: 0){
                            Image(systemName: "lock.shield")
                            Text("Private")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.15))
                        )
                    }
                    
                    Text((trail.StartTime.formatted()))
                        .font(.caption)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                    
                }
                .padding(.bottom,10)
                
                
                // color selected
                if showColorSelector {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(pastelColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        setTrailColor(color)
                                    }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                
                Divider().padding(.trailing,15)//.frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            }
            .padding(.top,10)
            .padding(.leading,15)
        }
            
           
        if(!(detent == .large || deviceOrientation.isLandscape || UIDevice.isIPad)){
            TrailInfoView(trail: trail)
        }
               
                  
                  
        if(detent == .large || deviceOrientation.isLandscape || UIDevice.isIPad){
              ScrollView{
                  
                  
//                  Text("From" + " " + trail.DisplayName)
//                      .frame(maxWidth: .infinity, alignment: .leading)
//                      .font(.footnote)
//                      .padding(.leading,15)
                  
                  TrailInfoView(trail: trail)
            
                  
                  HStack{
                      Text("From:").font(.caption)
                     Text(trail.DisplayName).font(.headline)
                  }
                  .frame(maxWidth: .infinity,alignment: .leading)
                  .padding(.bottom,5)
                  
                  
                   HStack{
                       Text("Difficulty:").font(.caption)
                       Text(trail.difficutly.localized).font(.headline)
                   }
                   .frame(maxWidth: .infinity,alignment: .leading)
                   .padding(.bottom,5)
                  
                  
                  TextCaptionWithDivider(text: "Description").padding(.bottom,5)
                  
                  if(!trail.TrailDesc.isEmpty){
                      Text(trail.TrailDesc)
                          .font(.callout)
                          .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.bottom,5)}else{
                          Text("No description").font(.footnote).italic()
                          .frame(maxWidth: .infinity, alignment: .leading)
                      }
                  
                  
                  
                 TextCaptionWithDivider(text: "WayPoints").padding(.bottom,5)
                 WayPointsList_SubView(wayPoints: $trail.WayPoints)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .padding(.bottom,5)
                
                  Divider()
                  GridView(storageID: trail.id.uuidString, labelFont: .caption)
                  
                  
                  
                  if(withMap){
                      TextCaptionWithDivider(text: "Map Preview").padding(.bottom,5)

                      Button{  showBigMap = true}
                      label:{
                          MapWithTrailSubView(trail: trail)
//                          .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.width / 2, alignment: .center)
                         // .border(.paste lGreen,width:2)
                         // .shadow(color: Color.black.opacity(0.2), radius: 5.0, x: -10.0, y: -10.0)
                          .shadow(color: Color.black.opacity(0.2), radius: 5, x: -10.5, y: 0.0)
                          .shadow(color: Color.black.opacity(0.2), radius: 5, x: 10.0, y: 0.0)
                          .padding(10)
                          .frame(width: UIScreen.main.bounds.width - 40 , height: UIScreen.main.bounds.width / 2, alignment: .center)
                          .sheet(isPresented: $showBigMap) {
                              MapWithTrailsSheet(trail: trail, isPresented: $showBigMap)
                                 // .padding(.top,25)
                                  .presentationDragIndicator(.hidden)
                          }
                      }
                  }
                  
                  if(withBottomControlButtons){
                      TextCaptionWithDivider(text: "Control").padding(.bottom,5)
                      
                                    Button{
                                        userModel.centerMap_toLocation(location: trail.StartLocation)
                                        userModel.tabSelected = .navigator
                                        userData.trailsInAreaNeedToSelect = trail.id
                                       
                                    }
                                    label:{
                                        Text("Open in Navigator")
                                    }
                                    .buttonStyle(ButtonDefault(ButtonColor: .pastelBlue ,width: (UIScreen .main.bounds.width / 3) * 2.0))
                      
                      
                  }


                  
              }
            }
                    
               
               
        }
       
            .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
            .padding(10)
            .background{
                if(withBackground){
                    Image(chooseRandomImage()).resizable()
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,maxWidth: .infinity)
                        .ignoresSafeArea()
                        .opacity(0.5)
                }
            }
           
         
//            .onAppear{
//                print("TrailDetailedView Appear")
//                self.loadPhoto()
//            }
//            .onChange(of: userModel.annotationSelector.selectedTrailID, {
//                print("selectedTrailID changed")
//                self.loadPhoto()})

            .detectOrientation($deviceOrientation)
           
        
            .onAppear{
                dataStorage.loadTrailImages(trail: trail)
            }
            
        
        

    }
    
    private func loadPhoto(){
//        Task{
//            //TRAIL IMAGES
//            if(dataStorage.getStorage(trail.id) == nil){
//                dataStorage.createStorage(workDir: trail.id.uuidString, id: trail.id)
//                
//                //add trails photos
//                dataStorage.getStorage(trail.id)!.addItems(trail.images)
//                
//                //add waypoints photos
//                if(!trail.WayPoints.isEmpty){
//                    for i in 0...trail.WayPoints.count-1{
//                        //add waypoint images to general gallery
//                        dataStorage.getStorage(trail.id)!.addItems(trail.WayPoints[i].images)
//                    }
//                }
//            }
//            
//            //WAYPOINT IMAGES
//            if(!trail.WayPoints.isEmpty){
//                for i in 0...trail.WayPoints.count-1{
//                    if(dataStorage.getStorage(trail.id ) == nil){
//                        dataStorage.createStorage(workDir: trail.id.uuidString, id: trail.WayPoints[i].id)
//                        dataStorage.getStorage(trail.id)!.addItems(trail.WayPoints[i].images)
//                    }
//                }
//            }
//            
//            print("LOADING PHOTO DONE!")
//        }

    }
    
                
        
    
    
}


struct TrailDetailedView_Preview : PreviewProvider {

    
    static var previews: some View {
        
        @State var userData = UserData()
        @State var userModel = UserModel()
        @ObservedObject var dataStorage = DataStorage()
        @State var detent = PresentationDetent.large
        @State var isPinned = false
        @State var sheetPresent = true
        @State var showColorSelector = false
      
            TrailDetailedView(
                trail: $userData.trailsOnMap[0],
                detent:  $detent,
                isPinned: $isPinned,
                sheetPresent: $sheetPresent,
                trailColorChanged: .constant(false),
             
                withMap: true,
                withBottomControlButtons : true
                
                
            )
            .environmentObject(userModel)
            .environmentObject(userData)
            .environmentObject(dataStorage)
      
            .environment(\.locale, .init(identifier: "ru"))
       
    }
}
    
