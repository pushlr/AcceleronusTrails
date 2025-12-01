//
//  UserModel.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 20.10.2023.
//

import Foundation
import MapKit
import Polyline
import SwiftUI

class UserModel: ObservableObject  {
    
//    @EnvironmentObject var userData : UserData
  //  private var db = Firestore.firestore()
    
    //@Published var userData = UserData()
 //   @EnvironmentObject var userData : UserData
    @Published var map = MKMapView()
 
    
  //  var dbd = DataBaseManager(userData: &userData)


    //location manager variable
    @Published var locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation
    @Published var lastSpeed: CLLocationSpeed
    @Published var lastGPSStrenght: CLLocationAccuracy
    @Published var weakGPSSignal = false
    
        
    var coordinateBottomLeft : CLLocationCoordinate2D?
    var coordinateTopRight : CLLocationCoordinate2D?
    var region : MKCoordinateRegion?

    @Published var recordingStatus : RecordingStatus = RecordingStatus.isStoped
    
    
    @Published var annotationSelector = MapAnnotationSelector()
    @Published var trailRecorded = Trail()
    
    @Published var currentActivity : ActivityType = .HIKING
    
    @Published var trailRecordedSettings = RecordingTrailSettings()
    
    @Published var searchAreTooBig = false
    
    @Published var userAverageColor : UIColor = .purple
    
    @Published var tabSelected: Tab = .navigator
//    @Published var navigationPath = NavigationPath()
    
    @Published var language : String = ""
    
    
  
    var tempWayPoint : WayPoint
    
    
    init(){
        print("UserModel Object is innited")
        lastLocation = CLLocation(latitude: 0, longitude: 0)
        lastSpeed = CLLocationSpeed(0)
        lastGPSStrenght = CLLocationAccuracy(-1)
        trailRecorded = Trail()
        tempWayPoint = WayPoint()

    //        trailRecorded.TrailName = "Campulung"
//        trailRecorded.DisplayName = "user2"
//        trailRecorded.TrailDesc = "The Yosemite Wilderness has over 750 miles of trail to explore with a great range of elevation, ecological zones, and solitude. This backpacking trip, be it your first or fortieth, is a uniquely protected opportunity to provide maximum freedom to roam in Wilderness. So, in planning a trip, it is important to find the right experience for your interests, timeframe, and abilities. "
//        trailRecorded.TrailDistance = 49968
//        trailRecorded.StartTime = Date()
//        trailRecorded.EndTime = Date()//Calendar.current.date(byAdding: .hour, value: 17, to: trailRecorded.StartTime)!
//        trailRecorded.TotalTime = 100000
//        trailRecorded.coordinateRecorded.insert(CLLocationCoordinate2D(latitude: 47.525039, longitude: 25.562707), at: trailRecorded.coordinateRecorded.count)
//        trailRecorded.coordinateRecorded.insert(CLLocationCoordinate2D(latitude: 47.64286, longitude: 26.24937), at: trailRecorded.coordinateRecorded.count)
//        
//        trailRecorded.WayPoints.append(WayPoint(name: "Test",desc: "desc1", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test2",desc: "desc2", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test3",desc: "desc3", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test4",desc: "desc4", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test5",desc: "desc5", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test6",desc: "desc6", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))

        

        
       
    }
    
    

//    func loadTrailFromUserDefaults(){
//        recordingStatus = RecordingStatus(rawValue: UserDefaults.standard.string(forKey: "recordingStatus") ?? "") ?? .isStoped
//        
//        if(recordingStatus != .isStoped){//if prev trail was not finished
//            
//        }
//        
//    }
    
//    func saveTrailToUserDefaults() {
//        print("store \(recordingStatus.rawValue)")
//        UserDefaults.standard.set(recordingStatus.rawValue, forKey: "recordingStatus")
//       
//        
//        UserDefaults.standard.set(trailRecorded.activityType.rawValue, forKey: "ActivityType")
//        UserDefaults.standard.set(trailRecorded.StartTime, forKey: "StartTime")
//        UserDefaults.standard.set(trailRecorded.EndTime, forKey: "EndTime")
//        UserDefaults.standard.set(trailRecorded.MovingTime, forKey: "MovingTime")
//        UserDefaults.standard.set(trailRecorded.TotalTime, forKey: "TotalTime")
//        UserDefaults.standard.set(encodeCoordinates(trailRecorded.coordinateRecorded), forKey: "Polyline")
//        UserDefaults.standard.set(trailRecorded.TrailDistance, forKey: "Distance")
//        UserDefaults.standard.set(trailRecorded.AltitudeMax, forKey: "AltitudeMax")
//        UserDefaults.standard.set(trailRecorded.SpeedMax, forKey: "SpeedMax")
//        
//        
//        //trailRecordedSettings
//        UserDefaults.standard.set(trailRecordedSettings.activeTracking, forKey: "tr_settings_activeTracking")
//        UserDefaults.standard.set(trailRecordedSettings.lineColor, forKey: "tr_settings_lineColor")
//        
//
//    }
    
    

    
    func StartRecording(){
        locationManager.startUpdatingLocation()
        trailRecorded = Trail()
        trailRecorded.activityType = currentActivity
        recordingStatus = RecordingStatus.isStarted
        
        //trailRecordedSettings.activeTracking = false
       
        
        //screen always on
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
     
    }
    
    func StopRecording(){
        
        recordingStatus = RecordingStatus.isStoped
        locationManager.stopUpdatingLocation()

        trailRecorded.EndTime = Date()
        
        //clear temp trail data
        //clearcoordinateRecorded()
        map.removeOverlay(trailRecorded.polyline)
        map.removeAnnotation(trailRecorded.StartPin)
        removeWayPoints(wayPoints: trailRecorded.WayPoints)
        
        //screen always on
       // UIApplication.shared.isIdleTimerDisabled = false
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }

       
    }
    
    func PauseRecording(){
        recordingStatus = RecordingStatus.isPaused
        locationManager.stopUpdatingLocation()
        //saveTrailToUserDefaults()
        
    }
    
    func ResumeRecording(){
        recordingStatus = RecordingStatus.isStarted
        locationManager.startUpdatingLocation()
    }
    

    
    
    func clearcoordinateRecorded(){
        trailRecorded.coordinateRecorded.removeAll()
        trailRecorded.TrailDistance=0
    }
    
    func centerMap_toLastLocation(){
        print("centering to \(lastLocation.coordinate)")
        if(lastLocation.coordinate.latitude != 0){
            let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude ), latitudinalMeters: 2000, longitudinalMeters: 2000)
            map.setRegion(viewRegion, animated: true)
        }
    }
    
    func centerMap_toLocation(location : CLLocationCoordinate2D){
        print("Center map to location")
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        map.setRegion(viewRegion, animated: true)
    }
    
    
    func timeFromStart(now: Date) ->String{
        return TimeDifference(from: trailRecorded.StartTime, to: now)
    }
    
    
    
    func removeWayPoint(wayPoint: WayPoint?){
        guard wayPoint != nil else {return}
        map.removeAnnotation(wayPoint!.annotation)
    }
    
    func removeWayPoints(wayPoints: [WayPoint]){
        guard !wayPoints.isEmpty else {return}
        
        for i in 0...wayPoints.count-1{
            removeWayPoint(wayPoint: wayPoints[i])
        }
        
    }
    
    func getWayPoint(id: UUID) -> WayPoint? {
        return trailRecorded.WayPoints.first(where: {$0.id == id})
    }
    
    func getWayPointIndex(id: UUID) -> Int? {
        return trailRecorded.WayPoints.firstIndex(where: {$0.id == id})
    }
    
    
    func drawWayPoint(wayPoint: inout WayPoint){
        wayPoint.annotation = WayPointAnnotation(trailID: -1, wayPointID: wayPoint.id)
        wayPoint.annotation.coordinate = wayPoint.coordonates.coordinate
        wayPoint.annotation.title = wayPoint.name
        wayPoint.annotation.annotationType = .WayPoint
        map.addAnnotation(wayPoint.annotation)
    }
    
    func drawStartLocation(){
        trailRecorded.StartPin = TrailAnnotation(trailID: 0, activityType: trailRecorded.activityType)
        trailRecorded.StartPin.coordinate = trailRecorded.StartLocation
        trailRecorded.StartPin.title = "Start Point"
        trailRecorded.StartPin.annotationType = AnnotationType.StartRecording
        map.addAnnotation(trailRecorded.StartPin)
    }
    
    func drawPolyline(trail: inout Trail){
        //draw lines
        map.removeOverlay(trail.polyline)
        trail.polyline =
        MyCustomPolyline(coordinates: trail.coordinateRecorded,
                         count: trail.coordinateRecorded.count)
        trail.polyline.color = UIColor(trailRecordedSettings.lineColor)
        map.addOverlay(trail.polyline)
    }
    

    
    func DrawFriends(friend: inout FriendInfo){
        //draw friends polylines
        print("Driwing friends polylines")
        
        //check last updated time
        let dist = friend.trailRecorded.lastUpdateTime.distance(to: Date())
        print("dist=\(dist)")
        if (dist > 60 * 10){
            //no updates last 10 minutes
            print("no updates last \(dist/60) minutes")
            friend.recordingStatus = .isStoped
        }
       
        
        if(friend.recordingStatus == .isStoped){
            map.removeAnnotation(friend.EndPin)
            map.removeOverlay(friend.polyline)
            return
        }
        
        //draw polyline
        map.removeOverlay(friend.polyline)
        friend.polyline =
        MyCustomPolyline(coordinates: friend.trailRecorded.coordinateRecorded,count: friend.trailRecorded.coordinateRecorded.count)
        friend.polyline.color = friend.polylineColor
        map.addOverlay(friend.polyline)
            
        //draw annotation
        if (map.annotations.firstIndex(where: {$0.title == friend.DisplayName}) == nil)  { // if annotation not exist  - create it
            friend.EndPin = FriendTrailAnnotation(activityType: friend.trailRecorded.activityType, 
                                                  FriendID: friend.userID,
                                                 
                                                  PolyLineColor: friend.polylineColor)
             friend.EndPin.coordinate = friend.trailRecorded.EndLocation
             friend.EndPin.title = friend.DisplayName
             map.addAnnotation(friend.EndPin)
        }else{//change annotation position
            friend.EndPin.coordinate = friend.trailRecorded.EndLocation
        }
        
        
    }
    
    func DrawTrailsInArea(trails: inout [Trail]){
        print("")
                    //show user trails
        if(trails.count>0){
            //    delete old pins
            //for i in 0...trailsInArea.count-1 {
             //   if(TrailsInArea[i].StartPin != nil)
             //   {map.removeAnnotation(TrailsInArea[i].StartPin)}
                
                
                //add new pins
            for i in 0...trails.count-1 {
                    //add point if is in visible area
                if(trails[i].StartPin.trailID == -1)
                    {
                    //print("add point with trailID \(i) and name: \(trails[i].TrailName)")
                    trails[i].StartPin = TrailAnnotation(trailID: i,activityType: trails[i].activityType)
                    trails[i].StartPin.coordinate = trails[i].StartLocation
                    trails[i].StartPin.title = "Start Point"
                    trails[i].StartPin.annotationType  = .TrailStartPoint
                    map.addAnnotation(trails[i].StartPin)
                    } else
                    {
                        //print("point already added")
                    }
                    
                    
                }
            }
        
    }
    
    func DeleteTrailsInArea(trails: inout [Trail]){
        if(trails.count>0){
            for i in 0...trails.count-1 {
                if(trails[i].StartPin != nil)
                {print("delete anotation \(i)")
                    map.removeAnnotation(trails[i].StartPin)
                    map.removeOverlay(trails[i].polyline)
                    
                }
            }
        }
    }
    
    
    

//    
    func AddNewWayPoint(){
        tempWayPoint =  WayPoint(name: "",
                                 desc: "",
                                 coordonates: CLLocation(latitude: 0, longitude: 0),
                                 mileage: 0,
                                 images: [])
        
      
    }
   
    
    
    
}

