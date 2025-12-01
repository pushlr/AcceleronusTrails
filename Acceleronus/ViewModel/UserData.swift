//
//  UserData.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 26.10.2023.
//

import Foundation
import MapKit
import FirebaseFirestore
import Polyline
import SwiftUI
import GeoFireUtils


struct Listener{
    var id : String
    var listener : ListenerRegistration
}
class UserData : ObservableObject  {
    private var db = Firestore.firestore()
    @Published var changingTimes = 0
    
    @Published var userID : String = ""
    @Published var DisplayName : String = ""
    @Published var DisplayPhoto : String = ""
    @Published var email : String = ""
    @Published var CreationDate : Date?
    @Published var LastSignInDate : Date?
    @Published var LastActivity : Date?

    
    @Published var mytrails = [Trail]()
    @Published var trailsOnMap = [Trail]()
    @Published var trailsInArea = [Trail]()
    @Published var favoriteTrails = [Trail]()
//trailsInArea
        
    @Published var friendsSearchList = [FriendInfo]() //searchable list
    @Published var friendsList = Friends()    //friends list, loaded integral

      
    //Friends temp variables
    var friendsInfoListeners = [Listener]()
        
    
    //friendsSearch temp variables
    @Published var friendsSearchIsLoading = false
    @Published var friendsSearchCount = 0
    var friendsSearchCursor: DocumentSnapshot?
    
    //liveTracking temp variables
    var liveTrackingListeners = [Listener]()
    @Published var liveTrackingLoading = false
    @Published var liveTrackingFriendUpdated = [Int]()
   
    
    //trailsInArea temp variables
    @Published var trailsInAreaisLoading = false
    @Published var trailsInAreaCount = 0
    @Published var trailsInAreaNeedToSelect : UUID? = nil
    
    var tasksCounter = 0
    
    
    //myTrails temp variables
    @Published var myTrailsIsLoading = false
    @Published var myTrailsCountIsLoading = false
    @Published var myTrailsCountLoadError = false
    @Published var myTrailsCount = 0
    
    private var myTrailsCursor: DocumentSnapshot?
    
    
    //myTrailsSearch temp variables
    @Published var mytrailsSearch = [Trail]()
    @Published var myTrailsSearchCount = 0
    @Published var myTrailsSearchIsLoading = false
    var myTrailsSearchCursor: DocumentSnapshot?
    var myTrailsSearchTaskID : UUID?

    func SignOut(){
        //db.terminate()
        
        userID = ""
        DisplayName = ""
        DisplayPhoto = ""
        
        mytrails.removeAll()
        trailsOnMap.removeAll()
        favoriteTrails.removeAll()
        
        friendsSearchList.removeAll()
        friendsList.list.removeAll()
        
        friendsSearchCount = 0
        friendsSearchCursor = nil
        
        trailsInAreaCount = 0
        myTrailsCount = 0
        myTrailsCursor = nil
        
        mytrailsSearch.removeAll()
        myTrailsSearchCount = 0
        myTrailsSearchCursor = nil
    }
    
    init(){
        print("UserData Object is innited")
//        DisplayName = "Dorin Popescu"
//        CreationDate = Date()
//        LastActivity = Date()
//        
//        var trailRecorded = Trail()
//        trailRecorded.TrailName = "Campulung"
//        trailRecorded.DisplayName = "user2"
//        trailRecorded.TrailDesc = "The Yosemite Wilderness has over 750 miles of trail to explore with a great range of elevation, ecological zones, and solitude. This backpacking trip, be it your first or fortieth, is a uniquely protected opportunity to provide maximum freedom to roam in Wilderness. So, in planning a trip, it is important to find the right experience for your interests, timeframe, and abilities. "
//        trailRecorded.TrailDistance = 49968
//        trailRecorded.StartTime = Date()
//        trailRecorded.EndTime = Date()//Calendar.current.date(byAdding: .hour, value: 17, to: trailRecorded.StartTime)!
//        trailRecorded.TotalTime = 100000
//        trailRecorded.coordinateRecorded.insert(CLLocationCoordinate2D(latitude: 47.525039, longitude: 25.562707), at: trailRecorded.coordinateRecorded.count)
//        trailRecorded.coordinateRecorded.insert(CLLocationCoordinate2D(latitude: 47.64286, longitude: 26.24937), at: trailRecorded.coordinateRecorded.count)
//        trailRecorded.confidentiality = .Private
//        
//        trailRecorded.WayPoints.append(WayPoint(name: "Test",desc: "desc1", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test2",desc: "desc2", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test3",desc: "desc3", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test4",desc: "desc4", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test5",desc: "desc5", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailRecorded.WayPoints.append(WayPoint(name: "Test6",desc: "desc6", coordonates: CLLocation(latitude: 47.64286, longitude:  25.84937)))
//        trailsOnMap.append(trailRecorded)
//        mytrails.append(trailRecorded)
//        mytrailsSearch.append(trailRecorded)
//        myTrailsCount = 1
//        trailsInAreaCount = 1 
//////
//        
//        for i in 0...5 {
//            var trailRecorded2 = Trail()
//            trailRecorded2.TrailName = "Campulung2"+String(i)
//            trailRecorded2.DisplayName = "user2"
//            trailRecorded2.TrailDesc = "The Yosemite Wilderness has over 750 miles of trail to explore with a great range of elevation, ecological zones, and solitude. This backpacking trip, be it your first or fortieth, is a uniquely protected opportunity to provide maximum freedom to roam in Wilderness. So, in planning a trip, it is important to find the right experience for your interests, timeframe, and abilities. "
//            trailRecorded2.TrailDistance = 49968
//            trailRecorded2.StartTime = Date()
//            trailRecorded2.EndTime = Date()//Calendar.current.date(byAdding: .hour, value: 17, to: trailRecorded.StartTime)!
//            trailRecorded2.TotalTime = 100000
//            
//            loadedTrails.append(trailRecorded2)
//            mytrails.append(trailRecorded2)
//        }
        //DrawTrailsInArea()
        
        
        
//        
////        
//        var fr = FriendInfo(userID: "1", DisplayName: "Valera2",friendStatus: .requestAccepted)
//        fr.LastActivity = Date()
//        fr.CreationDate = Date()
//                    var trailRecorded2 = Trail()
//                    trailRecorded2.TrailName = "Campulung2"
//                    trailRecorded2.DisplayName = "user2"
//                    trailRecorded2.TrailDesc = "The Yosemite Wilderness has over 750 miles of trail to explore with a great range of elevation, ecological zones, and solitude. This backpacking trip, be it your first or fortieth, is a uniquely protected opportunity to provide maximum freedom to roam in Wilderness. So, in planning a trip, it is important to find the right experience for your interests, timeframe, and abilities. "
//                    trailRecorded2.TrailDistance = 49968
//                    trailRecorded2.StartTime = Date()
//                    trailRecorded2.EndTime = Date()//Calendar.current.date(byAdding: .hour, value: 17, to: trailRecorded.StartTime)!
//                    trailRecorded2.TotalTime = 100000
//        fr.mytrails.append(trailRecorded2)
//        fr.myTrailsCount = 1
//        fr.dataLoaded = true
//        fr.recordingStatus = .isStarted
//        friendsList.list.append(fr)
//        friendsList.list.append(fr)
//        friendsList.list.append(fr)
//
//        var fr2 = FriendInfo(userID: "1", DisplayName: "Valera2",friendStatus: .requestObtained)
//        fr2.LastActivity = Date()
//        fr2.CreationDate = Date()
//        friendsList.list.append(fr2)
//        
//        
//        friendsList.list.append(FriendInfo(userID: "2", DisplayName: "John",friendStatus: .requestAccepted))
//        friendsList.list.append(FriendInfo(userID: "3", DisplayName: "Rambo",friendStatus: .requestAccepted))
//        friendsList.list.append(FriendInfo(userID: "4", DisplayName: "Ionel",friendStatus: .requestNotSent))
//        friendsList.list.append(FriendInfo(userID: "5", DisplayName: "Basil",friendStatus: .requestObtained))

//        usersList.append(UserInfo(DisplayName: "Ion",friendRequestAccepted: false))
//        usersList.append(UserInfo(DisplayName: "Grigor",friendRequestAccepted: false))
//        usersList.append(UserInfo(DisplayName: "Sfeta",friendRequestAccepted: false))
        
    }
    
    
    
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = FileManager.default.documentDirectory.path()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func removeTrail(trailID : UUID){
        if let index = mytrails.firstIndex(where: { $0.id == trailID }){
            mytrails.remove(at: index)
            myTrailsCount -= 1
        }
        
        if let index = mytrailsSearch.firstIndex(where: { $0.id == trailID }){
            mytrailsSearch.remove(at: index)
            myTrailsSearchCount -= 1
        }
        
    }
    
    func SaveRecordedTrail(trail: Trail){
        if(trail.coordinateRecorded.count>1){
            mytrails.insert(trail, at: 0)
            
        }
    }
    
    func saveTrailSettingsUserDefaults(trailSettings: RecordingTrailSettings){
        //trailRecordedSettings
        UserDefaults.standard.set(trailSettings.activeTracking, forKey: "tr_settings_activeTracking")
        UserDefaults.standard.set(trailSettings.lineColor.rawValue, forKey: "tr_settings_lineColor")
        
        print("Setting color \(trailSettings.lineColor.rawValue)")
      
    }
    
    func saveLanguageToUserDefaults(lang: String){
        UserDefaults.standard.set(lang, forKey: "app_language")
    }
    
    func getLanguageFromUserDefaults(app_language: inout String){
        let defaults = UserDefaults.standard
        
        if(defaults.string(forKey: "app_language") != nil){
            app_language = defaults.string(forKey: "app_language") ?? ""
        }
    }
    
    
    func loadTrailRecordingSettings(trailSettings: inout RecordingTrailSettings) -> Bool {
        let defaults = UserDefaults.standard
       
        trailSettings.activeTracking = defaults.bool(forKey: "tr_settings_activeTracking")
        if(defaults.string(forKey: "tr_settings_lineColor") != nil){
            trailSettings.lineColor = Color(rawValue: defaults.string(forKey: "tr_settings_lineColor") ?? "") ?? RecordingTrailSettings().lineColor
        }
    
        return true
    }
    
    
    
    func saveTrailUserDefaults(trail: Trail){
        let defaults = UserDefaults.standard
        defaults.set(true,forKey: "trailNotSaved")
        defaults.set(trail.id.uuidString, forKey: "TrailID")
        defaults.set(trail.TrailDesc, forKey: "TrailDesc")
        defaults.set(trail.TrailName, forKey: "TrailName")
        defaults.set(trail.activityType.rawValue, forKey: "activityType")
        defaults.set(trail.StartTime, forKey: "StartTime")
        defaults.set(trail.EndTime, forKey: "EndTime")
        defaults.set(trail.MovingTime, forKey: "MovingTime")
        defaults.set(trail.TotalTime, forKey: "TotalTime")
        defaults.set(encodeCoordinates(trail.coordinateRecorded), forKey: "encodeCoordinates")
        defaults.set(trail.TrailDistance, forKey: "TrailDistance")
        defaults.set(trail.AltitudeMax, forKey: "AltitudeMax")
        defaults.set(trail.SpeedMax, forKey: "SpeedMax")
        defaults.set(trail.difficutly.rawValue, forKey: "difficutly")
        defaults.set(trail.confidentiality.rawValue, forKey: "confidentiality")
        defaults.set(PhotoItemsToString(items: trail.images), forKey: "images")
        
        //save Waypoints
        defaults.set(trail.WayPoints.count,forKey: "WayPointCount")
        if(!trail.WayPoints.isEmpty){
            for i in 0...trail.WayPoints.count-1 {
                    let WayPointName = "WayPoint\(i)"
                    defaults.set(trail.WayPoints[i].id.uuidString, forKey: WayPointName + "ID")
                    defaults.set(trail.WayPoints[i].name, forKey: WayPointName + "Name")
                    defaults.set(trail.WayPoints[i].time, forKey: WayPointName + "Time")
                    defaults.set(trail.WayPoints[i].desc, forKey: WayPointName + "Desc")
                    defaults.set(trail.WayPoints[i].mileage, forKey: WayPointName + "Mileage")
                    defaults.set(trail.WayPoints[i].coordonates.coordinate.latitude, forKey: WayPointName + "Latitude")
                    defaults.set(trail.WayPoints[i].coordonates.coordinate.longitude, forKey: WayPointName + "Longitude")
                    defaults.set(trail.WayPoints[i].coordonates.altitude, forKey: WayPointName + "Altitude")
                    defaults.set(PhotoItemsToString(items: trail.WayPoints[i].images), forKey: WayPointName + "Images")
                 
            }
        }
        
        
    }
    
    
    func loadTrailUserDefaults(trail: inout Trail ) -> Bool{
        let defaults = UserDefaults.standard
        let notSavedExist = defaults.bool(forKey: "trailNotSaved")
        if(!notSavedExist){ return false}
     
            trail.id = UUID(uuidString:  defaults.string(forKey: "TrailID") ?? "") ?? UUID()
            trail.TrailDesc = defaults.string(forKey: "TrailDesc") ?? ""
            trail.TrailName = defaults.string(forKey: "TrailName") ?? ""
            trail.activityType = ActivityType(rawValue: defaults.string(forKey: "activityType") ?? "") ?? .UNKNOWN
            trail.StartTime = (defaults.value(forKey: "StartTime") as? Timestamp)?.dateValue() ?? Date()
            trail.StartTime = (defaults.value(forKey: "EndTime") as? Timestamp)?.dateValue() ?? Date()
            trail.MovingTime = defaults.value(forKey: "MovingTime") as? UInt32 ?? 0
            trail.TotalTime = defaults.value(forKey: "TotalTime") as? UInt32 ?? 0
            trail.coordinateRecorded = decodePolyline(defaults.string(forKey: "encodeCoordinates") ?? "")!
            trail.TrailDistance = defaults.double(forKey: "TrailDistance")
            trail.AltitudeMax = defaults.double(forKey: "AltitudeMax")
            trail.SpeedMax = defaults.double(forKey: "SpeedMax")
            trail.difficutly = DifficultySteps(rawValue: defaults.string(forKey: "difficutly") ?? "") ?? .Standard
            trail.confidentiality = TrailConfidentiality(rawValue: defaults.string(forKey: "confidentiality") ?? "") ?? .Public
            trail.images = StringToPhotoItems(str: defaults.string(forKey: "images") ?? "")
        
            
            //waypoints
            let wayPointsCount = defaults.integer(forKey: "WayPointCount")
            
            if(wayPointsCount>0){
                for i in 0...wayPointsCount-1 {
                    let WayPointName = "WayPoint\(i)"
                    var tempWayPoint = WayPoint()
                    print("UserDefaults: loading " + WayPointName)
                    print("name: " + (defaults.string(forKey: WayPointName + "Name") ?? ""))
                 
                    
                    tempWayPoint.id = UUID(uuidString: defaults.string(forKey: WayPointName + "ID") ?? "") ?? UUID()
                    tempWayPoint.name = defaults.string(forKey: WayPointName + "Name") ?? ""
                    tempWayPoint.desc = defaults.string(forKey: WayPointName + "Desc") ?? ""
                    tempWayPoint.mileage = defaults.value(forKey: WayPointName + "Mileage") as? Double ?? 0
                    tempWayPoint.time = (defaults.value(forKey: WayPointName + "Time") as? Timestamp)?.dateValue() ?? Date()
                    tempWayPoint.coordonates = CLLocation(coordinate:
                                                            CLLocationCoordinate2D(latitude: defaults.value(forKey:  WayPointName + "Latitude") as? Double ?? 0,
                                                                                   longitude: defaults.value(forKey: WayPointName + "Longitude") as? Double ?? 0),
                                                          altitude: CLLocationDistance(defaults.value(forKey: WayPointName + "Altitude") as? Double ?? 0),
                                                          horizontalAccuracy: CLLocationAccuracy(0),
                                                          verticalAccuracy: CLLocationAccuracy(0),
                                                          timestamp: (defaults.value(forKey: WayPointName + "Time") as? Timestamp)?.dateValue() ?? Date()
                                                          
                    )
                    
                    tempWayPoint.images = StringToPhotoItems(str: defaults.string(forKey: WayPointName + "Images") ?? "")
                    
                    trail.WayPoints.append(tempWayPoint)
                }
            }
          
        
        
    
        
        
        return trail.coordinateRecorded.count>=2
        
    }
    
    
    
    func db_storeTrailRecorded(trail: Trail, recordingStatus: RecordingStatus) {
        print("Set TrailRecorded \(trail.coordinateRecorded.count)")

        db.document("users/\(userID)/TrailRecorded/Current").setData(
          [
           "UserID"          : userID,
           "RecordingStatus" : recordingStatus.rawValue,
           "ActivityType"    : trail.activityType.rawValue,
           "StartTime"       : trail.StartTime,
           "LastUpdate"  : Date(),
           "MovingTime"       : trail.MovingTime,
           "TotalTime"        : trail.TotalTime,
           
           "Polyline"        : encodeCoordinates(trail.coordinateRecorded),
           "Distance"        : trail.TrailDistance,
           "AltitudeMax"     : trail.AltitudeMax,
           "SpeedMax"        : trail.SpeedMax,
          ]
        )
    }
    
    func randomString(_ length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func randomDate() -> Date {
        return  Calendar.current.date(byAdding: .day, value: -Int.random(in: 1..<100), to: Date())!
    }
    
    
//    func db_DEBUG_fillMyTrails(t: Trail){
//        return
//        var trail = t
//        for i in 0...100 {
//            trail.id = UUID()
//            trail.TrailDesc = "test2" + randomString(Int.random(in: 0..<50))
//            trail.TrailName = "test2" + randomString(Int.random(in: 2..<15))
//            trail.StartTime = randomDate()
//            trail.EndTime = Calendar.current.date(byAdding: .hour, value: 1, to:  trail.StartTime)!
//            
//            db_AddNewTrail(trail: trail)
//        }
//        
//    }
    
    func db_AddNewTrail(trail: Trail){
        print("􀧒 db_AddNewTrail")
      //  let TrailName = trail.TrailName.replacingOccurrences(of: " ", with: "_") + String(format: "%d",trail.coordinateRecorded.count)
        let trailFolder = "users/\(userID)/Trails/\(trail.id.uuidString)"
        
        let hash = GFGeoHash(location: CLLocationCoordinate2D(latitude: trail.StartLocation.latitude, longitude: trail.StartLocation.longitude))
        
        db.document(trailFolder).setData(
          ["UserID"          : userID,
           "TrailDesc"       : trail.TrailDesc,
           "TrailName"       : trail.TrailName,
           "ActivityType"    : trail.activityType.rawValue,
           "StartTime"       : trail.StartTime,
           "EndTime"         : trail.EndTime,
           "MovingTime"       : trail.MovingTime,
           "TotalTime"        : trail.TotalTime,
           
           "Polyline"        : encodeCoordinates(trail.coordinateRecorded),
           "Distance"        : trail.TrailDistance,
           "AltitudeMax"     : trail.AltitudeMax,
           "SpeedMax"        : trail.SpeedMax,
           
           "Difficulty"      : trail.difficutly.rawValue,
           "Confidentiality" : trail.confidentiality.rawValue,
           "Images"          : PhotoItemsToString(items: trail.images),
           
           "keywordsForLookup": trail.TrailName.generateStringSequence(),
           
           //calculated variable
           "Start Location latitude" : trail.StartLocation.latitude,
           "Start Location longitude" : trail.StartLocation.longitude,
           "End Location latitude" : trail.EndLocation.latitude,
           "End Location longitude" : trail.EndLocation.longitude,
           "geohash"        : hash?.geoHashValue ?? ""
           
          

          ]
        )
        
        if(!trail.WayPoints.isEmpty){
            for i in 0...trail.WayPoints.count-1 {
                let WayPointName = trail.WayPoints[i].id.uuidString
                db.document("\(trailFolder)/WayPoints/\(WayPointName)").setData(
                [
                  "ID"        : trail.WayPoints[i].id.uuidString,
                  "Name"      : trail.WayPoints[i].name,
                  "Time"      : trail.WayPoints[i].time,
                  "Desc"      : trail.WayPoints[i].desc,
                  "Mileage"   : trail.WayPoints[i].mileage,
                  "Latitude"  : trail.WayPoints[i].coordonates.coordinate.latitude,
                  "Longitude" : trail.WayPoints[i].coordonates.coordinate.longitude,
                  "Altitude"  : trail.WayPoints[i].coordonates.altitude,
                  "Images"    : PhotoItemsToString(items: trail.WayPoints[i].images)
                ]
                )
            }
                  
        }
        
      }
                            
    @MainActor func db_getTrails(query: Query, type: Int, param1: Int = 0,boundingBox:BoundingBox = BoundingBox(),tasksCount: Int = 0){
        // #1 trailsInArea
        // #2 myTrails
        

        
        print("􀧒 db starting task")       
        //let taskID = UUID()
        if(type == 1 ){trailsInAreaisLoading = true}
        if(type == 2){myTrailsIsLoading = true}
        if(type == 4){
            friendsList.list[param1].myTrailsIsLoading = true
        }
       
        Task {
            do{
                let taskID = UUID()
//                if(type == 1 ){trailsInAreaisLoading = true}
//                if(type == 2){myTrailsIsLoading = true}
                
                //check and stop previous search task
                if(type == 3){
                    myTrailsSearchTaskID = taskID; //stop previous task
                    while(myTrailsSearchIsLoading){try await Task.sleep(nanoseconds: 1000000) }; //wait for stop
                    myTrailsSearchIsLoading = true
                }
//                if(type == 4){
//                    friendsList.list[param1].myTrailsIsLoading = true
//                }
//               
                
                print("􀧒 Get trails request")
                var documents : QuerySnapshot
                try await documents = query.getDocuments()
                print("􀧒 Obtained from server \(documents.count) Trails")
                
                if(type == 1 ){
                    trailsInAreaCount = 0
                    trailsInArea.removeAll()
                }
                
            
                //add new trails to existing
                if(!documents.isEmpty){
                    
                    if(type == 2 ){
                        //  mytrails.removeAll()
                        myTrailsCursor = documents.documents.last
                    }
                    
                    if(type == 3 ){
                        myTrailsSearchCursor = documents.documents.last
                    }
                    if(type == 4 ){
                        friendsList.list[param1].myTrailsCursor = documents.documents.last
                    }
                    
                    
                    for i in 0...documents.count-1 {
                                                
                        let data = documents.documents[i].data()
                        print("􀧒 Creating trail : \(data["TrailName"])  Type \(type)")
                        
                        var tempTrail = Trail()
                        tempTrail.id = UUID(uuidString: documents.documents[i].documentID) ?? UUID()
                        tempTrail.UserID = data["UserID"]  as? String ?? ""
                        tempTrail.TrailName = data["TrailName"] as? String ?? ""
                        tempTrail.activityType = ActivityType(rawValue: data["ActivityType"] as? String ?? "") ?? .UNKNOWN
                        tempTrail.TrailDesc = data["TrailDesc"] as? String ?? ""
                        tempTrail.StartTime =  (data["StartTime"] as? Timestamp)?.dateValue() ?? Date()
                        tempTrail.EndTime = (data["EndTime"] as? Timestamp)?.dateValue() ?? Date()
                        tempTrail.MovingTime = data["MovingTime"] as? UInt32 ?? 0
                        tempTrail.TotalTime = data["TotalTime"] as? UInt32 ?? 0
                        tempTrail.coordinateRecorded = decodePolyline((data["Polyline"] as? String ?? ""))!
                        tempTrail.TrailDistance = data["Distance"] as? Double ?? 0
                        tempTrail.AltitudeMax = data["AltitudeMax"] as? Double ?? 0
                        tempTrail.SpeedMax = data["SpeedMax"] as? Double ?? 0
                        tempTrail.difficutly = DifficultySteps(rawValue: data["Difficulty"] as? String ?? "") ?? .Standard
                        tempTrail.confidentiality  = TrailConfidentiality(rawValue: data["Confidentiality"] as? String ?? "") ?? .Public
                        tempTrail.images = StringToPhotoItems(str: data["Images"] as? String ?? "")
                        
                        //Getting username query
                        try await db.document("users/\(tempTrail.UserID)/").getDocument() { (querySnapshot, err) in
                            guard let documents = querySnapshot else {
                                print("􀧒 no documents")
                                self.trailsInAreaisLoading = false
                                return
                            }
                            
                            if let err = err {
                                print("􀧒 Error getting documents: \(err)")
                            } else {
                              //  print("􀧒 Getting displayName")
                                tempTrail.DisplayName = documents.get("DisplayName") as? String ?? ""
                                
                            }
                        }//userInfo snapshot
                        
                        //Getting Waypoints query
                        var WayPointsDocuments : QuerySnapshot
                        try await WayPointsDocuments = db.collection(documents.documents[i].reference.path+"/WayPoints")
                            .order(by: "Time", descending: false)
                            .getDocuments()
                        
                     //   print("􀧒 Waypoints count obtained = \(WayPointsDocuments.count)")
                        
                        if(!WayPointsDocuments.isEmpty){
                            for i in 0...WayPointsDocuments.count-1 {
                                let data = WayPointsDocuments.documents[i].data()
                                
                                var tempWayPoint = WayPoint()
                                tempWayPoint.id = UUID(uuidString: WayPointsDocuments.documents[i].documentID) ?? UUID()
                                tempWayPoint.name = data["Name"] as? String ?? ""
                                tempWayPoint.desc = data["Desc"] as? String ?? ""
                                tempWayPoint.mileage = data["Mileage"] as? Double ?? 0
                                tempWayPoint.time = (data["Time"] as? Timestamp)?.dateValue() ?? Date()
                                tempWayPoint.coordonates = CLLocation(coordinate: CLLocationCoordinate2D(latitude: data["Latitude"] as? Double ?? 0, longitude: data["Longitude"] as? Double ?? 0),
                                                                      altitude: CLLocationDistance(data["Altitude"] as? Double ?? 0),
                                                                      horizontalAccuracy: CLLocationAccuracy(0),
                                                                      verticalAccuracy: CLLocationAccuracy(0),
                                                                      timestamp: (data["Time"] as? Timestamp)?.dateValue() ?? Date()
                                                                      
                                )
                                
                                tempWayPoint.images = StringToPhotoItems(str: data["Images"] as? String ?? "")
                                
                                tempTrail.WayPoints.append(tempWayPoint)
                                
                            }
                        }
                        
                 
                   
                        if(type == 1 ){
                            //check if is not private trail
                            if(tempTrail.confidentiality == .Public || tempTrail.UserID == self.userID){ // is public or is my trail
                                // check bounding area, and add to trails in area
                                if (tempTrail.StartLocation.latitude >= boundingBox.minLat &&
                                    tempTrail.StartLocation.latitude <= boundingBox.maxLat &&
                                    tempTrail.StartLocation.longitude >= boundingBox.minLng &&
                                    tempTrail.StartLocation.longitude <= boundingBox.maxLng
                                ) || (boundingBox.minLat==0){
                                    
                                    trailsInAreaCount += 1; //show trails in area count on the navigation tab
                                    
                                    if(trailsInArea.first(where: {$0.id == tempTrail.id}) == nil ) {
                                        trailsInArea.append(tempTrail)
                                    }
                                } else {print("Not in selected aread!")}
                                
                                //if not already added - add it to trailsOnMap
                                if(trailsOnMap.first(where: {$0.id == tempTrail.id}) == nil ) {
                                    trailsOnMap.append(tempTrail)
                                }
                                    
                            }
                        }
                        
                        if(type == 2){
                            if(mytrails.first(where: {$0.id == tempTrail.id}) == nil ) {
                                mytrails.append(tempTrail)
                            }else{
                                print("Dublicate Trail Name \(tempTrail.TrailName)")
                            }
                        }
                        
                        if(type == 3){
                            if(taskID != myTrailsSearchTaskID){break} //end task if new search task was run
                            
                            mytrailsSearch.append(tempTrail)
                        }
                        
                        if(type == 4){
                            //check if is not private trail
                            if(tempTrail.confidentiality == .Public){
                                friendsList.list[param1].mytrails.append(tempTrail)
                            }
                        }
                        
                   
                        
                        
                    }
                }
                
                if(type == 1){tasksCounter+=1;if tasksCounter >= tasksCount {trailsInAreaisLoading = false}}
                if(type == 2){myTrailsIsLoading = false}
                if(type == 3){myTrailsSearchIsLoading = false}
                if(type == 4){friendsList.list[param1].myTrailsIsLoading = false}
                
                
                
                
            } catch {
                print("CANCELED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print(error.localizedDescription)
                trailsInAreaisLoading = false
                myTrailsIsLoading = false
                myTrailsSearchIsLoading = false
            }
            return true
        }
              
        
    
        print("􀧒 db after starting task")
       
        
    }
    
    @MainActor func db_GetCurrentAreaTrails(btLeft: CLLocationCoordinate2D?, tpRight: CLLocationCoordinate2D?) {
        print("􀧒 loading Trails in area: \(userID)")
        guard userID.isEmpty==false else {return}
        guard btLeft != nil else {return}
        guard tpRight != nil else {return}
        
        var query = db.collectionGroup("Trails")
        .whereField("Start Location longitude",  isGreaterThan: btLeft!.longitude)
        .whereField("Start Location longitude",  isLessThan: tpRight!.longitude)
      //  .whereField("Start Location latitude",  isGreaterThan: btLeft!.latitude)
      //  .whereField("Start Location latitude",  isLessThan: tpRight!.latitude)
        .limit(to: 50)
        
        
        db_getTrails(query: query,type: 1)
    }
    
    

    
    @MainActor func db_GetCurrentAreaTrailsNew(region: MKCoordinateRegion) {
        print("􀧒 loading Trails in area: \(userID)")
        guard userID.isEmpty==false else {return}
     
        
        
        let bounds = region.boundingBox(for: region)
        let queries = GFUtils.queryBounds(
            forLocation: CLLocationCoordinate2D(latitude: bounds.center.latitude, longitude: bounds.center.longitude),
            withRadius: bounds.radius
        )
        
        tasksCounter = 0
        for (index,query) in queries.enumerated() {
            var query = db.collectionGroup("Trails")
                .whereField("geohash", isGreaterThanOrEqualTo: query.startValue)
                .whereField("geohash", isLessThanOrEqualTo: query.endValue)
                .limit(to: 50)
            
            
            db_getTrails(query: query, type: 1, boundingBox : bounds, tasksCount : queries.count)
            
        }
    }
    
    

    @MainActor func db_GetMyTrails(limit: Int = 10) {
        
        print("􀧒 loading my Trails, UserID: \(userID)")
        guard userID.isEmpty==false else {return}
        
        //count first
        if(myTrailsCursor == nil){
            db_GetMyTrailsCount()
        }
        
        //trails
        var query = db.collection("users/\(userID)/Trails/")
            .order(by: "StartTime", descending: true)
            
        
        if(myTrailsCursor != nil){
            print("Start after \(myTrailsCursor!.data()!["TrailName"] as! String)")
            query = query.start(afterDocument: myTrailsCursor!)
        }
        
        query = query.limit(to: limit)
        
        db_getTrails(query: query,type: 2)
        
    }
    
    @MainActor func db_getFriendTrails(friendIndex: Int, limit: Int = 2){
        print("􀧒 loading Friends Trails, friendIndex: \(friendIndex)")
        guard friendIndex < friendsList.list.count else {return}
        
        var query = db.collection("users/\(friendsList.list[friendIndex].userID)/Trails/")
            .order(by: "StartTime", descending: true)
        
        if(friendsList.list[friendIndex].myTrailsCursor != nil){
            print("Start after \(friendsList.list[friendIndex].myTrailsCursor!.data()!["TrailName"] as! String)")
            query = query.start(afterDocument: friendsList.list[friendIndex].myTrailsCursor!)
        }
        
        query = query.limit(to: limit)
        
        db_getTrails(query: query,type: 4, param1: friendIndex)
        
    }
    

    
    @MainActor func db_GetMyTrailsByName(limit: Int = 10,contain: String) {
        
        print("􀧒 loading my Trails by name, UserID: \(userID), keywords: \(contain)")
        guard userID.isEmpty==false else {return}
                
        //get count first
        if(myTrailsSearchCursor == nil){
            db_GetMyTrailsSearchCount(contain: contain)
        }
        
        //get trails
        var query = db.collection("users/\(userID)/Trails/")
            .whereField("keywordsForLookup", arrayContains: contain.lowercased())
            
            //.whereField("TrailName", isGreaterThanOrEqualTo: contain)
            //.whereField("TrailName", isLessThan: contain + "z")
        
        if(myTrailsSearchCursor != nil){
            print("Start after \(myTrailsSearchCursor!.data()!["TrailName"] as! String)")
            query = query.start(afterDocument: myTrailsSearchCursor!)
        }
        
        query = query.limit(to: limit)
    
        
        db_getTrails(query: query,type: 3)
        
    }
    
    
    @MainActor func db_GetMyTrailsCount() {
        print("􀧒 loading my Trails Count \(userID)")
        myTrailsCountIsLoading = true
        myTrailsCountLoadError = false
        Task{
            do{
                let query = db.collection("users/\(userID)/Trails/")
                let countQuery = query.count
                let snapshot = try await countQuery.getAggregation(source: .server)
                myTrailsCount = Int(snapshot.count)
                myTrailsCountIsLoading = false

                print("􀧒 Obtained from server Trails Count : \(snapshot.count) Trails (db_GetMyTrailsCount)")
            }catch{
                print("db_GetMyTrailsCount Error Catched")
                myTrailsCountIsLoading = false
                myTrailsCountLoadError = true
            }
        }
    }
    
    @MainActor func db_GetMyTrailsSearchCount(contain: String) {
        print("􀧒 loading my Trails Count \(userID)")
        myTrailsSearchCount = 0
        Task{
            do{
                let query = db.collection("users/\(userID)/Trails/").whereField("keywordsForLookup", arrayContains: contain.lowercased())
                let countQuery = query.count
                let snapshot = try await countQuery.getAggregation(source: .server)
                
                myTrailsSearchCount = Int(snapshot.count)
                print("􀧒 Obtained from server Trails Count : \(snapshot.count) Trails (db_GetMyTrailsSearchCount)")
                
            }catch{
                
            }
        }
    }
    
    @MainActor  func db_SearchUser(limit: Int = 10,contain : String){
        print("􀧒 db_SearchUser")
 
        //count first
        if(friendsSearchCursor == nil){
            db_GetFriendsSearchCount(contain: contain)
        }
        
        print("not equal to \(self.DisplayName)")
        var query = db.collection("users")
            .whereField("UserID", isNotEqualTo: self.userID)
            .whereField("keywordsForLookup", arrayContains: contain.lowercased())
         //   .whereField("keywordsForLookup", notIn: self.DisplayName.generateStringSequence())
//            .whereField("DisplayName", isGreaterThanOrEqualTo: contain)
//            .whereField("DisplayName", isLessThan: contain + "z")
            
        
        if(friendsSearchCursor != nil){
            print("Start after \(friendsSearchCursor!.data()!["DisplayName"] as! String)")
            query = query.start(afterDocument: friendsSearchCursor!)
        }
        
        query = query.limit(to: limit)
        
        friendsSearchIsLoading = true
        query.getDocuments() { (querySnapshot, err) in
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                     print("no documents")
                    self.friendsSearchIsLoading = false
                     return
                 }
                
                
                print("􀧒 Users found count: \(documents.count)")
                self.friendsSearchCursor = documents.last
             
                for i in 0...documents.count-1 {
                    let data = documents[i].data()
                    
                    print("Creating user \(data["DisplayName"] as? String ?? "")")
                    
                    var tempUser = FriendInfo()
                    tempUser.userID = data["UserID"] as? String ?? ""
                    tempUser.DisplayName = data["DisplayName"] as? String ?? ""
                    tempUser.DisplayPhoto = data["DisplayPhoto"] as? String ?? ""
                    tempUser.friendStatus = .requestNotSent
                    
                    //is my friend
                    if(self.friendsList.list.first(where: {$0.userID == tempUser.userID}) != nil){
                       tempUser = self.friendsList.list.first(where: {$0.userID == tempUser.userID})!
                    }

                    self.friendsSearchList.append(tempUser)
                    
                }
            
                self.friendsSearchIsLoading = false
                self.changingTimes += 1
            }
       
    }
    
    @MainActor func db_GetFriendsSearchCount(contain: String) {
        print("􀧒 loading my Friends Count \(contain)")
        
        Task{
            var query = db.collection("users")
                .whereField("UserID", isNotEqualTo: self.userID)
                .whereField("keywordsForLookup", arrayContains: contain.lowercased())
               // .whereField("keywordsForLookup", notIn: self.DisplayName.generateStringSequence())
//                .whereField("DisplayName", isGreaterThanOrEqualTo: contain)
//                .whereField("DisplayName", isLessThan: contain + "z")
           // let query = db.collection("users/\(userID)/Trails/").whereField("keywordsForLookup", arrayContains: contain.lowercased())
            let countQuery = query.count
            let snapshot = try await countQuery.getAggregation(source: .server)
            
            friendsSearchCount = Int(snapshot.count)
            print("􀧒 Obtained Search Friends Count : \(snapshot.count) ")
        }
    }
    
    
    
    func db_RemoveTrail(trailID: UUID){
        print("􀧒 removing trail \(trailID)")
        
        //remove trail and waypoints
        db.collection("users/\(userID)/Trails/\(trailID.uuidString)/WayPoints").getDocuments() { (querySnapshot, err) in
            if let documents = querySnapshot?.documents  {
                
                if(documents.count>0){
                    for i in (0...documents.count-1).reversed() {
                        documents[i].reference.delete()
                    }
                }
                
            }
            
            
        }
        
        //db.document("users/\(userID)/Trails/\(trailID.uuidString)/WayPoints").delete()
        db.document("users/\(userID)/Trails/\(trailID.uuidString)").delete()
        
        
        
    }
    
    
    func db_removeAccountInfo(){
        db.document("users/\(userID)/TrailRecorded/Current").delete()
      //  db.collection("users/\(userID)/TrailRecorded")
        db.document("users/\(userID)").delete()
    }

    func db_FirnedInfoListener(friendIndex : Int) -> ListenerRegistration{
        return self.db.document("users/\(self.friendsList.list[friendIndex].userID)/").addSnapshotListener { (querySnapshot, err) in
            if let documents = querySnapshot {
                if err == nil {
                    print("􀧒 Getting displayName Friend")
                   
                    let index = self.friendsList.list.firstIndex(where: {$0.userID == documents.get("UserID") as? String ?? ""})
                    if(index != nil ){
                        self.friendsList.list[index!].DisplayName = documents.get("DisplayName") as? String ?? ""
                        self.friendsList.list[index!].DisplayPhoto = documents.get("DisplayPhoto") as? String ?? ""
                        self.friendsList.list[index!].CreationDate = (documents.get("CreationDate") as? Timestamp)?.dateValue() ?? Date()
                        self.friendsList.list[index!].LastActivity = (documents.get("LastActivity") as? Timestamp)?.dateValue() ?? Date()                     
                        
                    }
                    
                    self.changingTimes += 1
                }
            }
        }
    }
    
    func db_FriendRecordedTrailLisneter(friendIndex: Int) -> ListenerRegistration{
        return self.db.document("users/\(self.friendsList.list[friendIndex].userID)/TrailRecorded/Current").addSnapshotListener { (querySnapshot, err) in
        if let documents = querySnapshot  {
            let index = self.friendsList.list.firstIndex(where: {$0.userID == documents.get("UserID") as? String ?? ""})
            print("db_FriendRecordedTrailLisneter \(index)")
           
            if(index != nil){
                print("setting \(index!) value " + (documents.get("RecordingStatus") as? String ?? ""))
                self.friendsList.list[index!].recordingStatus =  RecordingStatus(rawValue: documents.get("RecordingStatus") as? String ?? "") ?? .isStoped
                self.friendsList.list[index!].trailRecorded.activityType = ActivityType(rawValue: documents.get("ActivityType") as? String ?? "") ?? .UNKNOWN
                self.friendsList.list[index!].trailRecorded.StartTime = (documents.get("StartTime") as? Timestamp)?.dateValue() ?? Date()
                self.friendsList.list[index!].trailRecorded.MovingTime = (documents.get("MovingTime") as? UInt32) ?? 0
                self.friendsList.list[index!].trailRecorded.TotalTime = (documents.get("TotalTime") as? UInt32) ?? 0
                self.friendsList.list[index!].trailRecorded.lastUpdateTime = (documents.get("LastUpdate") as? Timestamp)?.dateValue() ?? Date()
                
                self.friendsList.list[index!].trailRecorded.coordinateRecorded = decodePolyline((documents.get("Polyline") as? String ?? ""))!
                self.friendsList.list[index!].trailRecorded.TrailDistance = (documents.get("Distance") as? Double) ?? 0
                self.friendsList.list[index!].trailRecorded.AltitudeMax = (documents.get("AltitudeMax") as? Double) ?? 0
                self.friendsList.list[index!].trailRecorded.SpeedMax = (documents.get("SpeedMax") as? Double) ?? 0
               
                //store
                self.liveTrackingLoading = true
                self.liveTrackingFriendUpdated.append(index!)
            }
            self.changingTimes += 1
        } else
        {
        print("TrailRecorded no documents")
        }
            
        }
        
    }
    
    
    @MainActor func db_GetFriendInfo(friendIndex: Int){
        print("􀧒 loading Trails Count for user \(self.friendsList.list[friendIndex].userID))")
        self.friendsList.list[friendIndex].isLoading = true
        
        Task{
            //loading friends trails count, Public trails only
            let query = db.collection("users/\(self.friendsList.list[friendIndex].userID)/Trails/").whereField("Confidentiality", isEqualTo: TrailConfidentiality.Public.rawValue)
            let countQuery = query.count
            let snapshot = try await countQuery.getAggregation(source: .server)
            self.friendsList.list[friendIndex].myTrailsCount = Int(snapshot.count)

            //loading firnes friends count
            let query2 = db.collection("users/\(self.friendsList.list[friendIndex].userID)/Friends/")
            let countQuery2 = query2.count
            let snapshot2 = try await countQuery2.getAggregation(source: .server)
            self.friendsList.list[friendIndex].myFriendsCount = Int(snapshot2.count)

            
            self.friendsList.list[friendIndex].isLoading = false
            self.friendsList.list[friendIndex].dataLoaded = true
            
            print("􀧒 Obtained from server Trails Count : \(snapshot.count) Trails (db_GetFriendInfo)")
        }
        
        
    }
    
    
    func db_ListenToUserData(){
        print("􀧒 db_ListenToUserData, userID: \(userID)")
        guard userID.isEmpty==false else {return}
        
        //USERDATA SNAPSHOT LISTENER
        db.document("users/\(userID)/").addSnapshotListener(){ (querySnapshot, err) in//.getDocuments() { (querySnapshot, err) in
            guard let documents = querySnapshot else {
                print("􀧒 no documents")
                return
            }
            
            // 🛑 Ignore local writes
            if documents.metadata.hasPendingWrites {
                print("􀧒 db_ListenToUserData : Ignoring local pending write")
                return
            }
            
            if let err = err {
                print("􀧒 Error getting documents: \(err)")
            } else {
                print("􀧒 Getting displayName")
                
                print("name: \(documents.get("DisplayName"))")
                print("photo: \(documents.get("DisplayPhoto"))")
              
//                print("isFromCache:", querySnapshot?.metadata.isFromCache ?? false)
//                print("hasPendingWrites:", querySnapshot?.metadata.hasPendingWrites ?? false)
                
                self.DisplayName = documents.get("DisplayName") as? String ?? ""
                self.DisplayPhoto = documents.get("DisplayPhoto") as? String ?? ""
                self.email = documents.get("Email") as? String ?? ""
                
                self.changingTimes += 1
            }
        }
        
        
        //FRIENDSLIST SNAPSHOT LISTENER
        db.collection("users/\(userID)/Friends").addSnapshotListener(){ (querySnapshot, err) in//.getDocuments() { (querySnapshot, err) in
            if let documents = querySnapshot?.documents{
                if(documents.isEmpty) {
                    self.friendsList.list.removeAll()
                }
                if(!documents.isEmpty) && (err == nil){
                    
                    print("􀧒 Friends count : \(documents.count)")
                   
                    //check for deleted users
                    if(self.friendsList.list.count>0){
                        for i in (0...self.friendsList.list.count-1).reversed() {
                            var del = true
                            for j in 0...documents.count-1 {
                                if(self.friendsList.list[i].userID == documents[j].documentID){
                                    del = false
                                }
                            }
                            if(del){
                                self.friendsList.list.remove(at: i)
                            }
                        }
                    }
                    
                    //check for users changes, or new users
                    for i in 0...documents.count-1 { 
                        let data = documents[i].data()
                        
                        //check if exist
                        let index = self.friendsList.list.firstIndex(where: {$0.userID == documents[i].documentID})
                        if(index == nil ){
                            //new user added
                            var tempUser = FriendInfo()
                            tempUser.userID = documents[i].documentID
                            tempUser.friendStatus = FriendStatus(rawValue: data["RequestStatus"] as? String ?? "")!
                            print("add Friend to list ")
                            self.friendsList.list.append(tempUser)
                            
                            //FRIEND INFO LISTENER
                            self.friendsInfoListeners.append(Listener(id: self.friendsList.list[self.friendsList.list.count-1].userID,
                                                                       listener: self.db_FirnedInfoListener(friendIndex: self.friendsList.list.count-1)))
                            
                            
                            //RECORDED TRAIL LISTENER
                            if(self.friendsList.list[self.friendsList.list.count-1].friendStatus == .requestAccepted){
                                print("Live tracking listener 1 \(self.friendsList.list[self.friendsList.list.count-1])")
                                self.liveTrackingListeners.append(Listener(id: self.friendsList.list[self.friendsList.list.count-1].userID,
                                                                          listener: self.db_FriendRecordedTrailLisneter(friendIndex: self.friendsList.list.count-1)))
                            }
                            
                        } else{
                            //changes
                            print("Friend \(self.friendsList.list[index!].DisplayName) already exist index=\(index), changing.. ")
                            self.friendsList.list[index!].friendStatus = FriendStatus(rawValue: data["RequestStatus"] as? String ?? "")!
                            
                            //Check if request status changesd
                            if(self.friendsList.list[index!].friendStatus == .requestAccepted){
                                print("Live tracking listener 2 \(self.friendsList.list[index!])")
                                //if lisneter not exist - add it
                                if(self.liveTrackingListeners.firstIndex(where: {$0.id == self.friendsList.list[index!].userID}) == nil){
                                    self.liveTrackingListeners.append(Listener(id: self.friendsList.list[index!].userID,
                                                                                       listener: self.db_FriendRecordedTrailLisneter(friendIndex: index!)))
                                }
                            }
                        }
                    }
                    
                    self.changingTimes += 1
                    
                }
            }
        }
               
       
}
    
    
    
    func db_sendFriendRequest(friend: FriendInfo){
        print("􀧒 sendFriendRequest UserID = \(userID)")
        db.document("users/\(friend.userID)/Friends/\(self.userID)").setData(
            [
                "RequestStatus" : FriendStatus.requestObtained.rawValue
            ]
        )
        
        db.document("users/\(self.userID)/Friends/\(friend.userID)").setData(
            [
                "RequestStatus" : FriendStatus.requestSent.rawValue
            ]
        )
        
    }
    
    func db_acceptFriendRequest(friend: FriendInfo){
        print("􀧒 db_acceptFriendRequest UserID = \(userID)")
        db.document("users/\(friend.userID)/Friends/\(self.userID)").setData(
            [
                "RequestStatus" : FriendStatus.requestAccepted.rawValue
            ]
        )
        
        db.document("users/\(self.userID)/Friends/\(friend.userID)").setData(
            [
                "RequestStatus" : FriendStatus.requestAccepted.rawValue
            ]
        )
        
    }
    
    func db_deleteFriend(friend: FriendInfo){
        print("􀧒 db_deleteFriend UserID = \(friend.DisplayName)")
        db.document("users/\(friend.userID)/Friends/\(self.userID)").delete()
        db.document("users/\(self.userID)/Friends/\(friend.userID)").delete()
        
    }
    
    func waitForFinish() async{
        try! await db.waitForPendingWrites()
    }
    


    func db_SaveUserDataBaseInfo(){//saved at each start
        print("􀧒 db_SaveUserDataElementary")
        guard userID.isEmpty==false else {return}
        
        db.document("users/\(userID)").setData(
            ["UserID" : userID,
             "DisplayName" : DisplayName,
             "Email"       : email,
             "CreationDate" : CreationDate,
             "LastSignInDate" : LastSignInDate,
             "LastActivity" : LastActivity,
             "keywordsForLookup": DisplayName.generateStringSequence(),
            ], merge: true
        )
    }
    
    
    
    func db_SaveUserData(){
        print("􀧒 db_SaveUserData")
        guard userID.isEmpty==false else {return}
        
        db.document("users/\(userID)").updateData(
            [
             "DisplayName" : DisplayName,
             "keywordsForLookup": DisplayName.generateStringSequence(),
             "DisplayPhoto" : DisplayPhoto
            ]
        )
        
    }
    
    


    func db_UpdateLastActivity(){//saved at each start
        print("􀧒 db_UpdateLastActivity")
        guard userID.isEmpty==false else {return}
        
        db.document("users/\(userID)").setData(
            [
             "LastActivity" : LastActivity,
            ], merge: true
        )
    }
    
    
    
}

