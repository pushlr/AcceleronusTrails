//
//  Waypoint_ViewView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 31.10.2023.
//

import SwiftUI
import MapKit

struct Waypoint_ViewView: View {
    @EnvironmentObject var dataStorage : DataStorage
    var wayPoint : WayPoint
    

    var body: some View {
        VStack{
            
            VStack{
                Text(wayPoint.name)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
             
                    
                Text((wayPoint.time.formatted()))
                    .font(.caption)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                    
              
                Divider().frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            }
            .padding(.top,10)
            .padding(.leading,15)
            .padding(.bottom,15)
            
            
            HStack{
                
                WayPoint_CoordinatesSubView(wp_mileage: wayPoint.mileage,
                                            wp_coordinates: wayPoint.coordonates)
    
            }.padding(.bottom,15)
            
            Text(wayPoint.desc)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                .padding(.bottom,15)
            
            
            VStack{
                GridView(storageID: wayPoint.id.uuidString)
                }
                
            
            
            
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
        .padding(10)
        .background{
            Image(chooseRandomImage()).resizable()
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,maxWidth: .infinity)
                            .ignoresSafeArea()
                            .opacity(0.5)
        }
    }
}





#Preview {
    Waypoint_ViewView(wayPoint: WayPoint(
        id: UUID(),
        name: "Test Name",
        desc: "this is a waypoint description",
        time: Date(),
        coordonates: CLLocation(latitude: 25, longitude: 46),
        images: [DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg"),DataItem(name: "IMG_6378.jpeg")],
        annotation: WayPointAnnotation(trailID: 1, wayPointID: UUID())))
    .environmentObject(DataStorage())
    
    
}
