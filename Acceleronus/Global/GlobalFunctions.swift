//
//  GlobalFunctions.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 28.09.2023.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {

    /// Returns the distance between two coordinates in meters.
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }

}


func chooseRandomImage() -> String {
    let images = ["Image 1", "Image 2", "Image 3", "Image 4"]
    let result = "Image 1"//images.randomElement()!
    return result
}


func getRandomColor() -> UIColor {
    let colorArray = [UIColor.red, UIColor.blue, UIColor.yellow,UIColor.cyan, UIColor.magenta,
                      UIColor.purple, UIColor.systemMint, UIColor.systemPink, UIColor.systemTeal]
    
    
    return colorArray[.random(in: 0...colorArray.count - 1)]
    
}



func TimeDifference(from: Date,to: Date) -> String{
    let diffs = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: from, to: to);
    var result = ""
    
    if let days = diffs.day {if days>0 {
        result += String(format: "%d", days) + " ";
        if(days>1){result+="days".localized}else{result+="day".localized}
    }}
    if let hours = diffs.hour {
        if hours>0 {
            if(!result.isEmpty){result+=" "};
            result += String(format: "%d", hours) + " ";
            if(hours>1){result+="hours".localized}else{result+="hour".localized}
        }}
    if let minutes = diffs.minute {
        if minutes>0 {
            if(!result.isEmpty){result+=" "};
            result += String(format: "%d", minutes) + " ";
            if(minutes>1){result+="minutes".localized}else{result+="minute".localized}
        }}
    if(result == ""){
        if let seconds = diffs.second {
            if seconds>0 {
                result = String(format: "%d", seconds) + " ";
                if(seconds>1){result+="seconds".localized}else{result+="second".localized}
            }}
    }
    
    if(result == ""){result="-"}
    return result
    
}


func formatBytesSize(_ bytes: UInt64 ) -> String {
    switch bytes {
    case 0..<1024:
      return "\(bytes) bytes"
    case 1024..<(1024 * 1024):
      return "\(String(format: "%.2f", Double(bytes) / 1024)) kb"
    case 1024..<(1024 * 1024 * 1024):
      return "\(String(format: "%.2f", Double(bytes) / 1024 / 1024)) mb"
    case (1024 * 1024 * 1024)...UInt64.max:
      return "\(String(format: "%.2f", Double(bytes) / 1024 / 1024 / 1024)) gb"
    default:
      return "\(bytes) bytes"
    }
    
}

// seconds => days/hours/minutes/seconds
func FormatTime(seconds: UInt32) -> String {
    var result = ""
    let days = seconds / 86400
    let hours = (seconds % 86400) / 3600
    let minutes = ((seconds % 86400)  % 3600) / 60
    let sec = (((seconds % 86400)  % 3600) % 3600) % 60
    
//    if(days>0){result+=String(format: "%d",days)+" day";if(days>1){result+="s"}}
//    if(hours>0){if(!result.isEmpty){result+=" "};result+=String(format: "%d",hours)+" hour";if(hours>1){result+="s"}}
//    if(minutes>0){if(!result.isEmpty){result+=" "};result+=String(format: "%d",minutes)+" minute";if(minutes>1){result+="s"}}
//    if(result == ""){
//        if(sec>0){if(!result.isEmpty){result+=" "};result+=String(format: "%d",sec)+" second";if(sec>1){result+="s"}}
//    }
    
    if days>0 {
        result += String(format: "%d", days) + " ";
        if(days>1){result+="days".localized}else{result+="day".localized}
    }
    
    if hours>0 {
            if(!result.isEmpty){result+=" "};
            result += String(format: "%d", hours) + " ";
            if(hours>1){result+="hours".localized}else{result+="hour".localized}
        }
    
        if minutes>0 {
            if(!result.isEmpty){result+=" "};
            result += String(format: "%d", minutes) + " ";
            if(minutes>1){result+="minutes".localized}else{result+="minute".localized}
        }
    
    if(result == ""){
        
            if seconds>0 {
                result = String(format: "%d", seconds) + " ";
                if(seconds>1){result+="seconds".localized}else{result+="second".localized}
            }
    }
    
    
    if(result == ""){result="-"}
    return result
        
}


func FormatTimeMonthYear(_ date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let yearString = dateFormatter.string(from: date)
    
    dateFormatter.dateFormat = "LLLL"
    let monthString = dateFormatter.string(from: date)
    
    return monthString + " " + yearString
}

func FormatTimeDayTime(_ date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, HH:MM"
    return dateFormatter.string(from: date)
}

func FormatTimeLastActivity(_ date: Date) -> String {
    let diffs = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: date, to: Date());
    var result = ""
    
    //is few days ago
    if let days = diffs.day {if days>0 {
        result += String(format: "%d", days) + " ";
        if(days>1){result+="days".localized}else{result+="day".localized}
        result = result + " " + "ago".localized
    }}
    
    
    //is in last 24 hours, yesterday or today
    if(result == ""){
        if Calendar.current.isDateInToday(date){
            result += "Today".localized
        }else {
            result += "Yesterday".localized
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM"
        result += ", " + dateFormatter.string(from: date)
    }
    
    
    return result
}


func PointIsInRegion(point: CLLocationCoordinate2D, BottomLeft: CLLocationCoordinate2D?, TopRight: CLLocationCoordinate2D?) -> Bool {
    guard BottomLeft != nil else {return false}
    guard TopRight != nil else {return false}
    
    if(
        ((point.longitude > BottomLeft!.longitude) && (point.longitude < TopRight!.longitude)) &&
        ((point.latitude > BottomLeft!.latitude) && (point.latitude < TopRight!.latitude))
      )
    {
        return true
    }else{
        
        return false
    }
}


func StringToPhotoItems(str: String) -> [PhotoItem]{
    var strArray : [String]
    var result = [PhotoItem]()
    strArray = str.description.components(separatedBy: "||")
    guard !strArray.isEmpty else {return result}
    
    for i in 0...strArray.count-1{
        
        if(!strArray[i].isEmpty){
            result.insert(
                PhotoItem(name: strArray[i]),
                at: result.count)
        }
    }
    return result
}


func StringToPhotoItems(str: String) -> [DataItem]{
    var strArray : [String]
    var result = [DataItem]()
    strArray = str.description.components(separatedBy: "||")
    guard !strArray.isEmpty else {return result}
    
    for i in 0...strArray.count-1{
        
        if(!strArray[i].isEmpty){
            result.insert(
                DataItem(name: strArray[i]),
                at: result.count)
        }
    }
    return result
}


func PhotoItemsToString(items: [PhotoItem]) -> String {
    var oneLine = ""
    guard !items.isEmpty else {return oneLine}
    
    for i in 0...items.count-1 {
        oneLine = oneLine + "||"+items[i].name
    }
    
    return oneLine
}

func PhotoItemsToString(items: [DataItem]) -> String {
    var oneLine = ""
    guard !items.isEmpty else {return oneLine}
    
    for i in 0...items.count-1 {
        oneLine = oneLine + "||"+items[i].name
    }
    
    return oneLine
}


func removeFileExtension ( _ filename: String ) -> String {
    var components = filename.components(separatedBy: ".")
    guard components.count > 1 else { return filename }
    components.removeLast()
    return components.joined(separator: ".")
}


func speedToString(_ s: CLLocationSpeed) -> String{
    return String(format: "%.2f", s * 3.6) + "km/h"
}

func distanceToStringKM(_ s: Double) -> String{
    return String(format: "%.2f", (s/1000))+" km"
}

func SignalStrenghtText(signal: CLLocationAccuracy) -> String {
    if(signal < 10.0){return "Excellent".localized}
    if(signal > 10.0 && signal < 15.0) {return "Good".localized}
    if(signal > 15.0 && signal < 25.0) {return "Poor".localized}
    if(signal > 30.0 && signal < 100.0) {return "Bad".localized}
    if(signal > 100.0) {return "lost".localized}
    return "-"
}

func SignalStrenght_to5Bar(signal: CLLocationAccuracy) -> Int {
    if(signal < 10.0){return 5}
    if(signal > 10.0 && signal < 15.0) {return 4}
    if(signal > 15.0 && signal < 25.0) {return 3}
    if(signal > 30.0 && signal < 100.0) {return 2}
    if(signal > 100.0) {return 1}
    return 0
}




