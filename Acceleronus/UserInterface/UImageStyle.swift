//
//  UImageStyle.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 25.10.2023.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func roundedImageWithBorder(width: CGFloat, 
                                color: UIColor,
                                bgColor: UIColor = .white) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height) + width * 3, height: min(size.width, size.height) + width * 3)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        imageView.layer.backgroundColor = bgColor.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        //        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let context = UIGraphicsGetCurrentContext()
        
        imageView.layer.render(in: context!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func reclangledImage(width: CGFloat, color: UIColor) -> UIImage? {
     //   let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
        let square = CGSize(width: size.width + width * 2, height: size.height + width * 2)
       
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = 7//square.width/2
        imageView.layer.masksToBounds = true
       // imageView.layer.borderWidth = width
       // imageView.layer.borderColor = color.cgColor
        imageView.layer.backgroundColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        //        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let context = UIGraphicsGetCurrentContext()
        
        imageView.layer.render(in: context!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    
    
     func triangle(side: CGFloat, color: UIColor)->UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: side, height: side), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: side / 2, y: 0))
        //### Add lines
        ctx.addLine(to: CGPoint(x: side, y: side))
        ctx.addLine(to: CGPoint(x: 0, y: side))
        //ctx.addLine(to: CGPoint(x: side / 2, y: 0)) //### path is automatically closed
        ctx.closePath()
        
        //ctx.setFillColor(color.cgColor)
        
        ctx.drawPath(using: .stroke) //### draw the path
        
        ctx.restoreGState()
                  
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}


extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}


extension UIImage {
     func imageWithColor(tintColor: UIColor) -> UIImage {
         UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

         let context = UIGraphicsGetCurrentContext()!
         context.translateBy(x: 0, y: self.size.height)
         context.scaleBy(x: 1.0, y: -1.0);
         context.setBlendMode(.normal)

         let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
         context.clip(to: rect, mask: self.cgImage!)
         tintColor.setFill()
         context.fill(rect)

         let newImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()

         return newImage
     }
 }





extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}



extension Color: RawRepresentable {

    public init?(rawValue: String) {
        
        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }
        
        do{
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        }catch{
            self = .black
        }
        
    }

    
    public var rawValue: String {
        
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
            
        }catch{
            
            return ""
            
        }
        
    }

}



extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
}




extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }

        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}


