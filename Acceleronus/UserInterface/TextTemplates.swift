//
//  TextTemplates.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 09.11.2023.
//

import Foundation
import SwiftUI


struct TextCaptionWithDivider: View {
    var text: LocalizedStringKey
    var body: some View {
        VStack{
            Divider()
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.caption)
        }
    }
    
}








extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
    
}



