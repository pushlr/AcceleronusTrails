//
//  ContentView.swift
//  Sticky Header
//
//  Created by Brandon Baars on 1/3/20.
//  Copyright © 2020 Brandon Baars. All rights reserved.
//

import SwiftUI
import _MapKit_SwiftUI
import StoreKit

extension Font {
    static func avenirNext(size: Int) -> Font {
        return Font.custom("Avenir Next", size: CGFloat(size))
    }
    
    static func avenirNextRegular(size: Int) -> Font {
        return Font.custom("AvenirNext-Regular", size: CGFloat(size))
    }
}

struct SaveTrailView: View {
    @Environment(\.requestReview) private var requestReview
    
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage
    
    @State var trail : Trail
    @Binding var showSaveTrailView : Bool
    
    @State var isShowingConfirmationDialog = false
    @State var selectActivitySheet = false
    
    
    @StateObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    
    private let imageHeight: CGFloat = 300
    private let collapsedImageHeight: CGFloat = 75
  
    
    var body: some View {
        VStack{
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        
                        Text("Save Trail")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom,15)
                        
                        TextField_WithTextLabel(title: "Trail Name", inputText: $trail.TrailName)
                        // .padding(.bottom,10)
                        
                        TextFiled_Multiline(title: "Description", inputText: $trail.TrailDesc)
                        //.padding(.bottom,10)
                        //Trail info
//                          TrailInfoView(trail: trail)
                        
                        //SELECT ACTIVITY
                        TextCaptionWithDivider(text: "Activity:")
                        Button(){withAnimation{selectActivitySheet.toggle()}
                        }label:{
                            VStack(alignment: .center, spacing: 0){
                                Image(GetActivity(trail.activityType).image)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                
                                Text(GetActivity(trail.activityType).name).foregroundStyle(.black)
                            }//.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom,5)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom,15)
                        
                        //Difficulty
                        TextCaptionWithDivider(text: "Difficulty:")
                        //Text(dificulty.rawValue).fontWeight(.semibold)
                        DificultyView
                            .padding(.bottom,15)
                        
                        //Confidential
                        
                        TextCaptionWithDivider(text: "Confidentiality:")
                        ConfidentialitySelectorView
                            .padding(.bottom,15)
                        
                        
                        //waypoints
                        TextCaptionWithDivider(text: "WayPoints").padding(.bottom,5)
                        WayPointsList_SubView(wayPoints: $trail.WayPoints, editMode: true )
                            .padding(.bottom,15)
                        
                        
                        
                        //gallery
                        Divider()
                        GridView(storageID: trail.id.uuidString, EditingMode: true,labelFont: .caption)
                            .frame(height: 600)
                        //.padding(.bottom,300)
                        
                        
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
                }
                .offset(y: imageHeight + 16)
                .background(GeometryGetter(rect: $articleContent.frame))
                
                GeometryReader { geometry in
                    // 3
                    ZStack(alignment: .bottom) {
                        // Map()
                        MapWithTrailSubView(trail: trail)
                        // Image("Image 1")
                        //  .resizable()
                        //   .scaledToFill()
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
//                .toolbar {
//                    
//                    ToolbarItemGroup(placement: .bottomBar) {
//                        DeleteTrailButton
//                    }
//                    
//                    ToolbarItem(placement: .bottomBar) {
//                        SaveTrailButton
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
//                    
//                }
            
            //change activity type
            .sheet(isPresented: $selectActivitySheet, content: {
                ActivitySelectorView(selectedActivity: $trail.activityType,
                                     isPresented: $selectActivitySheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            })
            
            
            VStack {
          
              HStack {
                  DeleteTrailButton
                Spacer()
                  SaveTrailButton
              }
              .padding()
              .background(Color(UIColor.systemBackground).shadow(radius: 2))
              
            }.padding(.bottom,2)
            
        }
//        .safeAreaInset(edge: .bottom) {
//          HStack {
//              DeleteTrailButton
//              Spacer()
//              SaveTrailButton
//          }
//         // .padding()
//          .background(.ultraThinMaterial)
//        }
        .onAppear{
            print("SaveTrailView appear")
//            if(dataStorage.getStorage(trail.id) == nil){
//                dataStorage.createStorage(workDir: trail.id.uuidString, id: trail.id)
//                dataStorage.getStorage(trail.id)!.items.removeAll()
//            }
//          
        }
        
        
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
    
    // 1
    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY
        
        // (x - min) / (max - min) -> Normalize our values between 0 and 1
        
        // If our Title has surpassed the bottom of our image at the top
        // Current Y POS will start at 75 in the beggining. We essentially only want to offset our 'Title' about 30px.
        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0 // What we consider our min for our scroll offset
            let maxYValue: CGFloat = collapsedImageHeight // What we start at for our scroll offset (75)
            let currentYValue = currentYPos

            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue)) // Normalize our values from 75 - 50 to be between 0 to -1, If scrolled past that, just default to -1
            let finalOffset: CGFloat = -30.0 // We want our final offset to be -30 from the bottom of the image header view

            // We will start at 20 pixels from the bottom (under our sticky header)
            // At the beginning, our percentage will be 0, with this resulting in 20 - (x * -30)
            // as x increases, our offset will go from 20 to 0 to -30, thus translating our title from 20px to -30px.
            
            return 20 - (percentage * finalOffset)
        }
        
        return .infinity
    }
    
    private func headerHeight(from geo: GeometryProxy) -> CGFloat {
           let offset = geo.frame(in: .named("parallaxScroll")).minY
           if offset > 0 {
               return imageHeight + offset
           }
           return imageHeight
       }

       private func headerOffset(from geo: GeometryProxy) -> CGFloat {
           let offset = geo.frame(in: .named("parallaxScroll")).minY
           if offset > 0 {
               return -offset
           } else {
               return 0
           }
       }

       private func blurRadius(from geo: GeometryProxy) -> CGFloat {
           let offset = geo.frame(in: .named("parallaxScroll")).maxY
           let height = geo.size.height
           // Simple blur formula
           let blur = (height - max(offset, 0)) / height
           return blur * 6
       }


    
    
    var DificultyView: some View {

        Picker("Difficulty",
               selection: $trail.difficutly) {
            ForEach(DifficultySteps.allCases,id: \.self){ item in
                Text(item.localized).tag(item)
            }
           
         
        }.pickerStyle(.segmented)
         .padding([.leading, .trailing], 5)

        
    }
    
    

    var ConfidentialitySelectorView: some View {
        
        VStack{
            Picker(//"Trail Confidentiality",
                selection: $trail.confidentiality,label: Text("s")) {
                    ForEach(TrailConfidentiality.allCases,id: \.self){ item in
                        Text(item.localized).tag(item)
                        
                    }
                    
                }
                .pickerStyle(.segmented)//.pickerStyle(.segmented)
                .padding([.leading, .trailing], 5)
                .onAppear {
                    //  UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(
                }
            
            switch(trail.confidentiality){
            case .Public:
                HStack{
                    Image(systemName: "lock.open")
                    Text("Public trail will be visible by other members, including WayPoint and photos.")
                        .font(.footnote)
                        .frame(maxWidth: .infinity,alignment: .leading)
                       
                }.padding([.leading,.trailing],15)
                 .padding(.top,5)
           case .Private:
                HStack{
                    Image(systemName: "lock.shield")
                    Text("Private trail will be unaivable for other members, also you cannot share it.")
                        .font(.footnote)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                        
                }.padding([.leading,.trailing],15)
                    .padding(.top,5)
            }
            
        }

        
    }
    

    
    
    var SaveTrailButton: some View{
        Button {
            //fill trail image struct from storage
            trail.images = dataStorage.getStorage(trail.id)?.items ?? []  //trailPhotoStorage.items
            
            //upload images
            dataStorage.uploadTrailImages(trail: trail)
            
            //first save to struct
            trail.DisplayName = userData.DisplayName  // add self display name for just saved trails,
            userData.SaveRecordedTrail(trail: trail)
            userData.myTrailsCount += 1
            
            //after save to db
            userData.db_AddNewTrail(trail: trail)
            
            UserDefaults.standard.set(false,forKey: "trailNotSaved") //dont read trail from backup at next start
            
            
            //userData.db_DEBUG_fillMyTrails(t: trail)
            showSaveTrailView=false
            
            //request rewiew
            if userData.myTrailsCount == 5 || userData.myTrailsCount == 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    requestReview()
                }
            }
            
        }
            
        } label: {
            Text("Save Trail")
        }
        .buttonStyle(
            ButtonDefault(
                Disabled: trail.TrailName.isEmpty,
                ButtonColor: Color.green,
                width: UIScreen.main.bounds.width / 2
            ))
        .disabled(trail.TrailName.isEmpty)
    }
    
    
    var DeleteTrailButton: some View{
        Button {
            isShowingConfirmationDialog.toggle()
            
        } label: {
            HStack{
                Image(systemName: "trash.circle")
                //      Text("Trash")
            }.frame(height: 5)
        }
        .buttonStyle(ButtonDefault(ButtonColor: Color.red, width: 50))
        .confirmationDialog("Are you sure?",
                            isPresented: $isShowingConfirmationDialog,
                            titleVisibility: .visible) {
            Button("Yes",role: .destructive) {
                UserDefaults.standard.set(false,forKey: "trailNotSaved") //dont read trail from backup at next start
                showSaveTrailView=false
            }
            //  Button("No", role: .destructive) { }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Recorded trail will be lost and cannot be restored!")
        }
    }
   
}

struct SaveTrailView_Previews: PreviewProvider {
    
    static var trailRecorded: Trail = {
        var t = Trail()
        t.TrailName = "Campulung"
        t.DisplayName = "user2"
        t.TrailDesc = "The Yosemite Wilderness …"
        t.TrailDistance = 49968
        t.StartTime = Date()
        t.EndTime = Date()
        t.TotalTime = 100000
        t.coordinateRecorded.append(CLLocationCoordinate2D(latitude: 47.525039, longitude: 25.562707))
        t.coordinateRecorded.append(CLLocationCoordinate2D(latitude: 47.64286, longitude: 26.24937))
        t.WayPoints.append(WayPoint(name: "Test", desc: "desc1", coordonates: CLLocation(latitude: 47.64286, longitude: 25.84937)))
        // ... add other waypoints similarly ...
        return t
    }()

    
    static var previews: some View {

        //
        SaveTrailView(trail: trailRecorded, showSaveTrailView: .constant(true))
            .environmentObject(UserModel())
            .environmentObject(DataStorage())
    }
}



class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}





