//
//  DeviceOrientation.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 04.11.2023.
//

import Foundation
import SwiftUI


struct DetectOrientation: ViewModifier {
    
    @Binding var orientation: UIDeviceOrientation
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                //ignore flat position
                if(UIDevice.current.orientation == .landscapeLeft ||
                   UIDevice.current.orientation == .landscapeRight ||
                   UIDevice.current.orientation == .portrait
                ){
                    orientation = UIDevice.current.orientation
                }
            }
    }
}



extension View {
    func detectOrientation(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DetectOrientation(orientation: orientation))
    }
}



extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
