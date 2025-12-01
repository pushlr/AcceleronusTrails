//
//  Extensions.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 01.12.2023.
//

import Foundation
import UIKit



extension URL {
    /// Indicates whether the URL has a file extension corresponding to a common image format.
    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
        return imageExtensions.contains(self.pathExtension)
    }
}



extension String {
    func generateStringSequence() -> [String] {
        /// E.g) "Mark" yields "M", "Ma", "Mar", "Mark"
        if self.isEmpty {return []}
        
        var words: [String] = self.components(separatedBy: " ")
        var sequences: [String] = []
        for i in 0...words.count-1{
            if words[i].isEmpty {continue}
            for j in 1...words[i].count {
                sequences.append(String(words[i].prefix(j)).lowercased())
            }
        }
       
        return sequences
    }
}



extension String {

  var localized: String {
    return NSLocalizedString(self, comment: "\(self)_comment")
  }
  
//  func localized(_ args: [CVarArg]) -> String {
//    return localized(args)
//  }
//  
//  func localized(_ args: CVarArg...) -> String {
//    return String(format: localized, args)
//  }
//    
    func localized(with value: Int) -> String {
      let format = NSLocalizedString(self, comment: "")
      return String(format: format, value)
    }

    func localized(with values: CVarArg...) -> String {
      let format = NSLocalizedString(self, comment: "")
      return String(format: format, locale: Locale.current, arguments: values)
    }
}


extension UIColor {
    static var randomPastel: UIColor {
        let hue = CGFloat.random(in: 0...1)            // random hue
        let saturation = CGFloat.random(in: 0.4...0.6) // pastel = medium-low saturation
        let brightness = CGFloat.random(in: 0.85...1)  // pastel = high brightness

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}





import MapKit

extension MKCoordinateRegion {

    /// Returns an approximate radius (in meters) of the visible region.
    var radiusApproximation: Double {
        let centerLocation = CLLocation(latitude: center.latitude,
                                        longitude: center.longitude)

        let cornerLocation = CLLocation(
            latitude: center.latitude + span.latitudeDelta / 2,
            longitude: center.longitude + span.longitudeDelta / 2
        )

        return centerLocation.distance(from: cornerLocation)
    }

    func boundingBox(for region: MKCoordinateRegion) -> BoundingBox {

            let center = region.center

            let minLat = region.center.latitude  - region.span.latitudeDelta  / 2
            let maxLat = region.center.latitude  + region.span.latitudeDelta  / 2
            let minLng = region.center.longitude - region.span.longitudeDelta / 2
            let maxLng = region.center.longitude + region.span.longitudeDelta / 2

            // Radius (meters) – approximate for geohash query
            let radiusMeters = region.radiusApproximation

        return BoundingBox(center: center, radius: radiusMeters, minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng)
        }
    
}
