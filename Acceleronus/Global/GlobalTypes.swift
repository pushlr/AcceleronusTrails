//
//  GlobalTypes.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 20.10.2023.
//

import Foundation
import MapKit
import SwiftUI
import FirebaseFirestore

enum RecordingStatus: String{
    case isStarted
    case isPaused
    case isStoped
}

enum DifficultySteps: String,CaseIterable{
    case Easy
    case Standard
    case Hard
    case Master
    
    var localized: LocalizedStringKey {
         LocalizedStringKey(self.rawValue)
     }


}

enum TrailConfidentiality: String, CaseIterable {
    case Public, Private
    
    var localized: LocalizedStringKey {
         LocalizedStringKey(self.rawValue)
     }
    
}


struct RecordingTrailSettings {
    var activeTracking = false
    var lineColor : Color = .green
    var lastStoredCoordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}

struct MapAnnotationSelector {

    var isTrailSelected = false
    var selectedTrailID = -1
    
    var isWayPointSelected = false
    var selectedWayPointID = UUID()
    
    var iscurrTrailWayPointSelected = false
    var selectedCurrTrailWayPointID = UUID()
    
}


enum FriendStatus: String, CaseIterable{
    case requestNotSent, requestSent, requestObtained, requestAccepted
}



struct Friends {
   
    var list = [FriendInfo]()
    var friendsActiveTracking : Int  {
        var cnt = 0
        if list.count > 0 {
            for i in 0...list.count-1 {
                if list[i].recordingStatus == .isStarted {
                    cnt += 1
                }
            }
        }
        return cnt
    }
    
   
    
}

struct FriendInfo : Identifiable {
    var id = UUID()
    
    // loaded in db_FirnedInfoListener function
    var userID : String = ""
    var DisplayName : String = ""
    var DisplayPhoto : String = ""
    var CreationDate : Date?
    var LastSignInDate : Date?
    var LastActivity : Date?
    
    //loading after in db_GetFriendInfo function
    var dataLoaded = false
    var isLoading = false
    
    //trails
    var mytrails = [Trail]()
    var myTrailsCount = 0
    var myTrailsCursor: DocumentSnapshot?
    var myTrailsIsLoading = false
    
    //friends
    var myFriendsCount = 0
    
    
    //loaded om db_ListenToUserData function
    var friendStatus : FriendStatus = .requestNotSent
    
    //loaded in db_FriendRecordedTrailLisneter function
    var recordingStatus : RecordingStatus = .isStoped
    var trailRecorded : Trail = Trail()
    var polyline = MyCustomPolyline()
    var polylineColor = getRandomColor()
    var EndPin   = FriendTrailAnnotation(activityType: .HIKING,FriendID: "", PolyLineColor: UIColor.red)
  
}


struct WayPoint : Identifiable {
    var id = UUID()
    var name : String = ""
    var desc : String = ""
    var time : Date = Date()
    var coordonates : CLLocation = CLLocation(latitude: 0, longitude: 0)
    var mileage = 0.0
    var images : [DataItem] = []
 
    var annotation = WayPointAnnotation(trailID: -1, wayPointID: UUID())
}


struct Trail : Identifiable {
    var id = UUID()
    var UserID = ""
    var DisplayName = ""
   
    
    //variable sync with server
    var TrailName : String = ""
    var TrailDesc = ""
    var activityType : ActivityType = .HIKING
    var color : UIColor = UIColor.orange
    var StartTime : Date = Date()
    var EndTime : Date = Date()
    var lastUpdateTime : Date = Date()
    var MovingTime : UInt32 = 0
    var TotalTime : UInt32 = 0 
    public var coordinateRecorded = [CLLocationCoordinate2D]()
    var TrailDistance : Double = 0
    var AltitudeMax : Double = 0
    var SpeedMax : Double = 0
    var difficutly : DifficultySteps = .Standard
    var confidentiality : TrailConfidentiality = .Public
    var images : [DataItem] = []
   
    //calculated variables
    var TotalTimeFormatted : String {
        return FormatTime(seconds: TotalTime)
    }
    
    var MovingTimeFormatted : String {
        return FormatTime(seconds: MovingTime)
    }
    
//    public var TimeFromStartFormatted : String {
//       return TimeDifference(from: StartTime, to: Date())
//    }
    
    var TrailDistanceFormatted : String { return distanceToStringKM(TrailDistance) }
    
    var StartLocation : CLLocationCoordinate2D {
        coordinateRecorded.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    var EndLocation : CLLocationCoordinate2D {
         coordinateRecorded.last ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    
    //Temp variables
    var StartPin = TrailAnnotation(trailID: -1, activityType: .HIKING)
    var EndPin   = TrailAnnotation(trailID: -1, activityType: .HIKING)
    var polyline = MyCustomPolyline()
    var polylineArrows = MyCustomPolylineArrows()
    var isPinned = false

    
    var WayPoints = [WayPoint]()
    
   

}








enum AnnotationType {
    case Default, StartRecording, StopRecording, TrailStartPoint, TrailEndPoint, WayPoint, FriendPosition, TempPin
}


class BaseAnnotation: MKPointAnnotation{
    var annotationType : AnnotationType
    
    init(annotationType: AnnotationType){
        self.annotationType = annotationType
    }
}

class TrailAnnotation: BaseAnnotation {
    var trailID : Int
    var activityType : ActivityType
  
    
    init(trailID: Int, activityType: ActivityType) {
          self.trailID = trailID
          self.activityType = activityType
          super.init(annotationType: .Default)
     }
    
}


class TemporaryAnotation: BaseAnnotation {
    var id : UUID = UUID()

}


class WayPointAnnotation: BaseAnnotation {
    var trailID : Int
    var wayPointID : UUID
    //var name : String
    init(trailID: Int, wayPointID: UUID) {
        self.trailID = trailID
        self.wayPointID = wayPointID
        //self.name = name
        super.init(annotationType: .WayPoint)
       
        
     }
    
}

class FriendTrailAnnotation: BaseAnnotation{
    var activityType : ActivityType
  //  var DisplayName : String
    var FriendID : String
   // var DisplayPhoto : URL
    var polylineColor : UIColor
   
    
    init(activityType: ActivityType, FriendID: String, /*DisplayPhoto: URL,*/ PolyLineColor : UIColor) {
          self.activityType = activityType
          self.FriendID = FriendID
        //  self.DisplayPhoto = DisplayPhoto
          self.polylineColor = PolyLineColor
          super.init(annotationType: .FriendPosition)
    }
}

class MyCustomPolyline : MKPolyline {

    var color: UIColor?
    var trailID: Int?
    
   
}

class MyCustomPolylineArrows : MKPolyline {

    var color: UIColor?
    
   
}





class MKAnnotationViewWithTitle: MKAnnotationView {
    var titleLabel: UILabel!
    var title : String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override var image: UIImage? {
        didSet {
            // Call commonInit to update the icon image
            commonInit()
        }
    }


    
    func commonInit() {
        // Remove existing subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }

        // Create and configure the title label
        titleLabel = UILabel(frame: CGRect(x: -50 + (image?.size.width ?? 2)/2, y: image?.size.height ?? 0 + 5, width: 100, height: 20)) //image?.size.width ?? 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 13,weight: .semibold)
        titleLabel.text = title ?? "Your Label"
        addSubview(titleLabel)
        

        // Adjust the size of the annotation view to accommodate both the icon and label
        frame = CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0 + 25)
    }
}




struct BoundingBox {
    let center: CLLocationCoordinate2D
    let radius: Double
    let minLat: Double
    let maxLat: Double
    let minLng: Double
    let maxLng: Double
    
    init(center: CLLocationCoordinate2D = CLLocationCoordinate2D(),
         radius: Double = 0,
         minLat: Double = 0,
         maxLat: Double = 0,
         minLng: Double = 0,
         maxLng: Double = 0)
    {
        // Default dummy values
        self.center = center
        self.radius = radius
        self.minLat = minLat
        self.maxLat = maxLat
        self.minLng = minLng
        self.maxLng = maxLng
        
        
    }
}

