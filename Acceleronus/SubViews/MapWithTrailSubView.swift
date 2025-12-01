//
//  MapWithTrailSubView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 29.11.2023.
//

import SwiftUI
import _MapKit_SwiftUI

struct MapWithTrailSubView: View {
    let trail : Trail
    
    
    var body: some View{
        
        Map{
            //Start Point
            Annotation("Start Point",
                       coordinate: trail.StartLocation,
                       content: {
                Image(uiImage:
                        (UIImage(named: GetActivity(trail.activityType).image)?
                            .withBackground(color: UIColor.white)
                            .roundedImageWithBorder(width: 3, color: UIColor.orange))!)
            })
            
            //End Point
            Annotation("End Point",
                       coordinate: trail.EndLocation,
                       content: {
                Image(uiImage:
                        (UIImage(named: "finish")?
                            .withBackground(color: UIColor.white)
                            .roundedImageWithBorder(width: 3, color: UIColor.orange))!)
            })
            
            //Draw WayPoints
            ForEach(trail.WayPoints){ wayPoint in
                Annotation(wayPoint.name,
                           coordinate: wayPoint.coordonates.coordinate,
                           content: {
                    Image(uiImage:(UIImage(named: "waypoint")?
                        .resizeImageTo(size: CGSize(width: 25, height: 25))?
                        .roundedImageWithBorder(width: 2, color: UIColor.orange))!)
                }
                )
            }
            
            //Draw polyline
            MapPolyline(coordinates: trail.coordinateRecorded)
                .stroke(.blue, lineWidth: 5)
            
        }
        .mapStyle(.hybrid)
        
        
        
        
    }
}

#Preview {
    MapWithTrailSubView(trail: Trail())
}
