//
//  Account_MyTrails.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 08.11.2023.
//

import SwiftUI
import _MapKit_SwiftUI

struct Account_MyTrails: View {
    @EnvironmentObject var userData : UserData
    @EnvironmentObject var dataStorage : DataStorage


    @State var searchText = ""
    @State var lastScheduledSearch: Timer?
    @State var showLoadingAnimation = false
    @State private var searchisPresented = false
    
    
    var searchResults: [Trail] {
            if searchText.isEmpty {
                return userData.mytrails
            } else {
               // return userData.mytrails.filter{$0.TrailName.lowercased().contains(searchText.lowercased())}
                return userData.mytrailsSearch
            }
        }
    
    
    var body: some View {
        
        VStack{
//            if(searchText.isEmpty && userData.myTrailsCount==0 && searchResults.count==0){
//                ContentUnavailableView(label: {Label("No trails recorded",systemImage: "tray.fill")},
//                                       description: {Text("Step into your adventures – captured trails will be here.")}
//                )//.frame(maxHeight: .infinity, alignment: .top)
//                
//            }
                ScrollView {
                    
                    ZStack {
                        
                        // MARK: - Content when no trails
                        if(searchText.isEmpty && userData.myTrailsCount==0 && searchResults.count==0){
                                     ContentUnavailableView(label: {Label("No trails recorded",systemImage: "tray.fill").font(.callout)},
                                                            description: {Text("Step into your adventures – captured trails will be here.").font(.footnote)}
                                     )//.frame(maxHeight: .infinity, alignment: .top)
                                     .padding(.top,UIScreen.main.bounds.height / 4)
                                 }
                        
                        // MARK: - Loading Indicator
                       
                        HStack {
                            if userData.myTrailsSearchIsLoading || showLoadingAnimation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                    .scaleEffect(1.0)      // Make it bigger
                                    .rotationEffect(.degrees(showLoadingAnimation ? 360 : 0))
                                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: showLoadingAnimation)
                            }
                           
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        
                        // MARK: - Search Result Count
                        if !searchText.isEmpty && !(userData.myTrailsSearchIsLoading || showLoadingAnimation) {
                            HStack {
                                Text("Found \(userData.myTrailsSearchCount) trails")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    
                    
                    LazyVStack{
                        ForEach(searchResults) { item in
       
                            
                            TrailCard(item: item)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Rectangle().fill(Color.white))
                                .cornerRadius(10)
                                .shadow(color: .gray, radius: 3, x: 0, y: 0)
                                .padding(5)
                                .onAppear{
                                    //   print("TrailCard appear: \(item.TrailName)")
                                    if(searchText.isEmpty){
                                        if (item.id == userData.mytrails.last!.id && !userData.myTrailsIsLoading) {
                                            userData.db_GetMyTrails()
                                        }
                                    }else{
                                        if (item.id == userData.mytrailsSearch.last?.id && !userData.myTrailsSearchIsLoading) {
                                            userData.db_GetMyTrailsByName(contain: searchText)
                                        }
                                    }
                                    
                                    
                                }
                                
                        }
                        
                        if(searchText.isEmpty){
                            //lazy load progress animation
                            if searchResults.count < userData.myTrailsCount{
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black)).padding(25)}
                        }else{
//                            if searchResults.count < userData.myTrailsSearchCount{
//                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black)).padding(25)}
                        }
                    }
                    
                }
                .listStyle(.plain)
                .searchable(text: $searchText,isPresented: $searchisPresented, placement: .navigationBarDrawer(displayMode: .always),   prompt: Text("Search") )
                
                .onAppear{
                    //load first trails
                    // loaded in MainView
                    //  userData.db_GetMyTrails()
                    if(userData.myTrailsCount==0 && userData.mytrails.count>0){
                        userData.db_GetMyTrailsCount() //if fail to load first time, trying to load again hzhzhzhzhzhzhzhzh
                    }
                }
                .onChange(of: searchText, {
                    if(!searchText.isEmpty ){
                        showLoadingAnimation = true
                        lastScheduledSearch?.invalidate() //cancel timer
                        
                        //run timer after 1 second
                        lastScheduledSearch = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block:
                                                                    {_ in
                            print("setting nil cursor")
                            userData.myTrailsSearchCursor = nil
                            userData.mytrailsSearch.removeAll()
                            userData.db_GetMyTrailsByName(contain: searchText)
                            showLoadingAnimation = false
                        })
                    }
                    
                }
                )
                
                .onChange(of: searchisPresented){ //cancel button clicked
                    print("isPresented: \(searchisPresented)");
                    if !searchisPresented {
                        searchText = ""
                        userData.mytrailsSearch.removeAll()
                    }
                }
                
                
           // }
            
        }.navigationTitle("My Trails (\(userData.myTrailsCount))")
            
       // }
    }
    
    
}




struct TrailCard: View {
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
                            Text(GetActivity(item.activityType).name)
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
                                                 trailColorChanged: .constant(false),
                                                 withTopControlButtons: false,
                                                 withBackground: false,
                                                 withMap: true,
                                                 withBottomControlButtons: true
                                                )
                               
                               
                               
                )
                {
                    Label("Details",systemImage: "ellipsis.rectangle")
                    
                }.padding(.trailing,10)
                
                NavigationLink(destination: EditTrailView(trail: item)) {
                    Label("Edit",systemImage: "square.and.pencil")
                    
                }.padding(.trailing,10)
                 .disabled(true)
                
                
                Button{print("deleteClicked");trailForDelete = item.id; }
            label:{Label("Remove",systemImage: "trash.slash").foregroundColor(.red)}
                    .confirmationDialog("Are you sure?",
                                        isPresented: $isShowingConfirmationDialog,
                                        titleVisibility: .visible) {
                        Button("Remove Trail", role: .destructive) {
                            //mytrails list
                            if(userData.mytrails.first(where: {$0.id == trailForDelete}) != nil){
                                dataStorage.removeTrailImages(trail: userData.mytrails.first(where: {$0.id == trailForDelete})!)
                            }
                            //search list, when searching trail new list is createad, check it
                            if(userData.mytrailsSearch.first(where: {$0.id == trailForDelete}) != nil){
                                dataStorage.removeTrailImages(trail: userData.mytrailsSearch.first(where: {$0.id == trailForDelete})!)
                            }
                            userData.db_RemoveTrail(trailID: trailForDelete);
                            userData.removeTrail(trailID: trailForDelete)
                           
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                                        .padding(.trailing,10)
                
                
            }
            
        }
        .onChange(of: trailForDelete, {print("on change"); isShowingConfirmationDialog.toggle() })
//        .border(.red)
        
    }
}
#Preview {
    Account_MyTrails()
        .environmentObject(UserData())
        .environmentObject(DataStorage())
}
