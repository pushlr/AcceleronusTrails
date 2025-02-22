//
//  WayPoint_CoordinatesSubView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 08.11.2023.
//

import SwiftUI
import MapKit

struct WayPoint_CoordinatesSubView: View {
    
    var wp_mileage : Double
    var wp_coordinates : CLLocation
    
    var body: some View {
        HStack{
            VStack{
                Text("Mileage:")
                Text(distanceToStringKM(wp_mileage))
                    .font(.caption)
                
            }
            
            VStack{
                Text("Latitude:")
                Text(String(format: "%.2f", wp_coordinates.coordinate.latitude))
                    .font(.caption)
                
            }
            VStack{
                Text("Longitude:")
                Text(String(format: "%.2f", wp_coordinates.coordinate.longitude)
                )
                .font(.caption)
            }
            
            VStack{
                Text("Altitude:")
                Text(String(format: "%.2f", wp_coordinates.altitude))
                    .font(.caption)
                
            }
            
            
        }
    }
}

#Preview {
    WayPoint_CoordinatesSubView(wp_mileage: 4, wp_coordinates: CLLocation(latitude: 0, longitude: 0))
}
