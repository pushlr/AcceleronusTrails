//
//  MapView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 27.09.2023.
//
import MapKit
import SwiftUI

    
struct MapView: UIViewRepresentable {
        
        @EnvironmentObject var userModel : UserModel
        @EnvironmentObject var userData: UserData
        @EnvironmentObject var dataStorage: DataStorage

        @Binding var trailSheetDismissed: Bool
        @Binding var wayPointSheetDismissed: Bool
        @Binding var trailColorChanged: Bool
        @Binding var selectedTrailUUID: UUID?
     
     
    
        func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
            print("makeUIView")
            userModel.map.showsUserLocation=true
            userModel.map.mapType=MKMapType.hybrid
            userModel.map.showsUserTrackingButton=true
            userModel.map.showsScale = true
            userModel.map.delegate = context.coordinator
            if(userModel.recordingStatus == .isStoped){ //if not recording, start with current position, else show unfinished trail
                userModel.map.userTrackingMode = .follow
            }
            
            
            //tap gesture
            let tap = UITapGestureRecognizer(target: context.coordinator,
                                              action: #selector(Coordinator.didTapMap(_:)))
            userModel.map.addGestureRecognizer(tap)

            //long tap gesture
            let longtap = UILongPressGestureRecognizer(target: context.coordinator,
                                              action: #selector(Coordinator.didLongTapMap(_:)))
            longtap.minimumPressDuration = 0.5  // adjust as needed
            longtap.delaysTouchesBegan = true
            userModel.map.addGestureRecognizer(longtap)
            
            
            return userModel.map
        }

    
        func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
            if ((selectedTrailUUID) != nil){
                context.coordinator.selectTrail(trailUUID: selectedTrailUUID!)
                DispatchQueue.main.async {
                    self.selectedTrailUUID = nil
                }
            }
            
            if trailSheetDismissed {
                context.coordinator.sheetTrailWasDismissed()
                
                // Reset so you don't trigger it repeatedly
                DispatchQueue.main.async {
                    self.trailSheetDismissed = false
                }
            }
            
            if wayPointSheetDismissed {
                context.coordinator.sheetWayPointWasDismissed()
                // Reset so you don't trigger it repeatedly
                DispatchQueue.main.async {
                    self.wayPointSheetDismissed = false
                }
            }
            
            if trailColorChanged {
                context.coordinator.trailColorChangedAction()
                // Reset so you don't trigger it repeatedly
                DispatchQueue.main.async {
                    self.trailColorChanged = false
                }
            }
            
            

        }
    
    
        func makeCoordinator() -> MapCoordinator {
            Coordinator(self)
        }
    
    
    func getAnnotationImage(annotation: BaseAnnotation, isSelected : Bool = false) -> UIImage? {
        
        var color = UIColor.orange
        if let trailAnnotation = annotation as? TrailAnnotation {
            let trailID = trailAnnotation.trailID
            print("Trails on map count: \(userData.trailsOnMap.count)")
            if trailID>=0 && userData.trailsOnMap.count > trailID{
                color = userData.trailsOnMap[trailID].color
            }
           
        }
        
        
        if let trailAnnotation = annotation as? WayPointAnnotation {
            let trailID = trailAnnotation.trailID
            if trailID>=0 && userData.trailsOnMap.count > trailID{
                color = userData.trailsOnMap[trailID].color
            }
        }
        
        
         switch annotation.annotationType {
                
            case .Default:
                return UIImage(systemName: "star.fill")
                
            case .StartRecording:
                return UIImage(named: "start")?
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 3, color: UIColor(red: 46, green: 159, blue: 78))
                
            case .StopRecording:
                return UIImage(systemName: "finish")?
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 3, color: isSelected ? UIColor.orange : UIColor.brown)
                
                
            case .TrailStartPoint:
             return UIImage(named: GetActivity((annotation as! TrailAnnotation).activityType).image)?
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 3, color: isSelected ? color: UIColor.brown)
                
            case .TrailEndPoint:
                return UIImage(named: "finish")?
                  //  .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 3, color: isSelected ? color: color) // finish always is selected
                
                
            case .FriendPosition:
//                return "pushlr".image(withAttributes: [.font: UIFont.systemFont(ofSize: 20.0)])!
//                    .withBackground(color: UIColor.white)
//                    .reclangledImageWithBorder(width: 3, color: isSelected ? UIColor.orange : UIColor.red)
             return UIImage(named: GetActivity((annotation as! FriendTrailAnnotation).activityType).image)?
                   // .withBackground(color: UIColor.orange)
                 .roundedImageWithBorder(width: 3, color: isSelected ? UIColor.orange : (annotation as! FriendTrailAnnotation).polylineColor, bgColor: .pastelMoloco)
                
            case .WayPoint:
                return isSelected ? 
                 UIImage(named: "waypoint")?
                //    .imageWithColor(tintColor: UIColor.systemRed)
                    .resizeImageTo(size: CGSize(width: 25, height: 25))?
                 
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 2, color: color)
                 :
                UIImage(named: "waypoint")?
                    .resizeImageTo(size: CGSize(width: 20, height: 20))?
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 2, color: UIColor.brown)
                   
             
         case .TempPin:
             return UIImage(systemName: "pin.fill")?
                // .withBackground(color: UIColor.white)
                 .roundedImageWithBorder(width: 2, color: .pastelOrange)
                
             }
        }
    

}
    

    


class MapCoordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var parent: MapView
    var tempAnnotations: [TemporaryAnotation] = []

  
    
    init(_ parent: MapView) {
        self.parent = parent
        super.init()
        parent.userModel.locationManager.delegate = self
        parent.userModel.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters  // check this for better battery performance
        parent.userModel.locationManager.requestWhenInUseAuthorization()
        parent.userModel.locationManager.allowsBackgroundLocationUpdates = true
        parent.userModel.locationManager.pausesLocationUpdatesAutomatically = false //!!
        parent.userModel.locationManager.activityType = .otherNavigation
        print("ABCD \(parent.userModel.locationManager.activityType)")
      
        //parent.userModel.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        //parent.userModel.locationManager.distanceFilter = 100
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //parent.userModel.locationManager.startUpdatingLocation()
        print("Application become alive!")
    }
    
    func isCoordinate(_ coord: CLLocationCoordinate2D,
                      nearPolyline polyline: MKPolyline,
                      tolerance: CGFloat,
                      in mapView: MKMapView) -> Bool {

        let tapPoint = mapView.convert(coord, toPointTo: mapView)

        // Get all screen points of the polyline
        var points: [CGPoint] = []
        for i in 0..<polyline.pointCount {
            let mapPoint = polyline.points()[i]
            points.append(mapView.convert(mapPoint.coordinate, toPointTo: mapView))
        }

        // Check tap distance to each segment
        for i in 0..<(points.count - 1) {
            let p1 = points[i]
            let p2 = points[i + 1]

            let distance = distanceFrom(tapPoint, toSegment: (p1, p2))

            if distance <= tolerance {     // usually 10–20 px
                return true
            }
        }

        return false
    }
    
    func distanceFrom(_ point: CGPoint, toSegment segment: (CGPoint, CGPoint)) -> CGFloat {
        let (p1, p2) = segment

        let dx = p2.x - p1.x
        let dy = p2.y - p1.y

        if dx == 0 && dy == 0 {
            return hypot(point.x - p1.x, point.y - p1.y)
        }

        let t = max(0, min(1, ((point.x - p1.x) * dx + (point.y - p1.y) * dy) / (dx*dx + dy*dy)))
        let proj = CGPoint(x: p1.x + t * dx,
                           y: p1.y + t * dy)

        return hypot(point.x - proj.x, point.y - proj.y)
    }

    
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            // Insert code here of what should happen when Location services are authorized
            print("authorizedWhenInUse")
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            print("restricted,denied")
            break
            
        case .notDetermined:        // Authorization not determined yet.
            print("notDetermined")
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        parent.userModel.locationStatus = status
        // print(#function, statusString)
        print("change status")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("LocationManager : didUpdateLocations")
        guard let location = locations.last else { return }
        //guard let location = locations.last(where: { $0.horizontalAccuracy >= 0 }) else { return }
        var lastDistance : Double = 0
        parent.userModel.lastLocation = location
        parent.userModel.lastSpeed = location.speed
       
        //gps signal strengh
        parent.userModel.lastGPSStrenght = location.horizontalAccuracy
        
        //store max speed
        if(location.speed > parent.userModel.trailRecorded.SpeedMax)
        {parent.userModel.trailRecorded.SpeedMax = location.speed}
        
        //store max altitude
        if(location.altitude > parent.userModel.trailRecorded.AltitudeMax)
        {parent.userModel.trailRecorded.AltitudeMax = location.altitude}
        
        
        //is good GPS signal?
        if(parent.userModel.lastGPSStrenght>20){
            print("low GPS Signal : \(parent.userModel.lastGPSStrenght)")
            parent.userModel.weakGPSSignal = true
            return
        }else{
            parent.userModel.weakGPSSignal = false
        }
        
        
        //is good location?
        if(parent.userModel.trailRecorded.coordinateRecorded.count>=1){
            if(parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-1]
                .distance(to:parent.userModel.lastLocation.coordinate)>5){
//                print("isGoodLocation")
            }else
            {
                print("isNotGoodLocation")
                return
            }
        }
        

        
        
        if(parent.userModel.recordingStatus == RecordingStatus.isStarted){
            
            //store coordinates
            parent.userModel.trailRecorded.coordinateRecorded.insert(location.coordinate, at: parent.userModel.trailRecorded.coordinateRecorded.endIndex)
            
            //draw lines
            parent.userModel.drawPolyline(trail: &parent.userModel.trailRecorded)
            
            //add Start place
            if(parent.userModel.trailRecorded.coordinateRecorded.count==1){
                parent.userModel.drawStartLocation()
                
                //center map to lastlocation
                parent.userModel.centerMap_toLastLocation()
            }
            
            
            //calculate distance between 2 last points
            if(parent.userModel.trailRecorded.coordinateRecorded.count>=2){
                // print("calculating distance \(parent.userData.coordinateRecorded.endIndex)")
                lastDistance = parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-2]
                                   .distance(to: parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-1]) as Double
                parent.userModel.trailRecorded.TrailDistance += lastDistance
            }
        }
                
        //save to UserDefault
        parent.userData.saveTrailUserDefaults(trail: parent.userModel.trailRecorded)
        
        
        //save coordonateRecordeded to db
        if(parent.userModel.trailRecordedSettings.activeTracking){
            let distance2 = parent.userModel.trailRecordedSettings.lastStoredCoordinates.distance(to:
                            parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-1]) as Double
            if(distance2>40){ //live tracking is updates each 40 metters
                print("Updating TrailRecorded")
                parent.userData.db_storeTrailRecorded(trail: parent.userModel.trailRecorded, recordingStatus: parent.userModel.recordingStatus)
                parent.userModel.trailRecordedSettings.lastStoredCoordinates =
                parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-1]
            }else{
                print("TrailRecording: Distance < 40")
            }
        }
        
        

        
    }
    
    
   
    
    //custom polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MyCustomPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = routePolyline.color
            renderer.lineWidth = 6
            renderer.lineCap = CGLineCap.square
            return renderer
        }
        
        if let polyline = overlay as? MyCustomPolylineArrows {
            print("rendering polyline arrows...")
            let customRenderer = CustomPolylineRenderer(overlay: overlay as! MyCustomPolylineArrows)
            return customRenderer
        }
        
        return MKOverlayRenderer()
    }
    

    
    //custom anotations
    func mapView(_ mapView: MKMapView, viewFor annotation:MKAnnotation)->MKAnnotationView?
    {
        //print("customAnnotation Rendering")
        if annotation is TrailAnnotation {
            let myannotation = (annotation as! TrailAnnotation)
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.image = parent.getAnnotationImage(annotation: myannotation)
            return view
        }
       
        if annotation is WayPointAnnotation {
            let myannotation = (annotation as! WayPointAnnotation)
            let view = MKAnnotationViewWithTitle(annotation: annotation, reuseIdentifier: nil)

            view.title = myannotation.title ?? ""
            view.image = parent.getAnnotationImage(annotation: myannotation)
            return view
        }
        
        if annotation is FriendTrailAnnotation {
            let myannotation = (annotation as! FriendTrailAnnotation)
            let view = MKAnnotationViewWithTitle(annotation: annotation, reuseIdentifier: nil)
            view.image = parent.getAnnotationImage(annotation: myannotation)!
            view.title = myannotation.title ?? ""
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
            detailLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            detailLabel.text = "Live tracking starting at " + (parent.userData.friendsList.list.first(where: {$0.userID == myannotation.FriendID})?.trailRecorded.StartTime.formatted() ?? "unknown")
            //detailLabel.text = parent.userData.friendsList.list.first(where: {$0.userID == myannotation.FriendID})?.trailRecorded.TrailDistanceFormatted
            detailLabel.font = UIFont(name: detailLabel.font.fontName, size: 15)
            
            
            view.detailCalloutAccessoryView = detailLabel
            view.canShowCallout = true
     
            return view
        }
        
        
        if annotation is TemporaryAnotation {
             let myannotation = (annotation as! TemporaryAnotation)
             let view = MKAnnotationViewWithTitle(annotation: annotation, reuseIdentifier: nil)

             view.title = myannotation.title ?? ""
             view.image = parent.getAnnotationImage(annotation: myannotation)
             return view
         }
    
        
        print("FATAL: Nill Annotation")
        return nil
    }
    
    
    func selectTrail(trailUUID: UUID) {
        print("Selecting trail by UUID")
        // Find the index of the trail with this UUID
        guard let index = parent.userData.trailsOnMap.firstIndex(where: { $0.id == trailUUID }) else {
            print("Trail with UUID \(trailUUID) not found")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
              guard let self = self else { return }
                let prevSelectedTrailID = parent.userModel.annotationSelector.selectedTrailID
                //deselect previous
                deselectTrail(trailID: prevSelectedTrailID)
                selectTrail(trailID: index)
          }
        
      
    }
           
    func selectTrail(trailID: Int,forceSelect: Bool = false){
        print("Selecting trail")
        //Generate Polyline
        if (!parent.userData.trailsOnMap[trailID].isPinned || forceSelect){
            //Draw poliline for selected trail
            parent.userData.trailsOnMap[trailID].polyline =
            MyCustomPolyline(coordinates: parent.userData.trailsOnMap[trailID].coordinateRecorded, count: parent.userData.trailsOnMap[trailID].coordinateRecorded.count)
            //Draw polyline arrwows
            parent.userData.trailsOnMap[trailID].polylineArrows =
            MyCustomPolylineArrows(coordinates: parent.userData.trailsOnMap[trailID].coordinateRecorded, count: parent.userData.trailsOnMap[trailID].coordinateRecorded.count)
            
            parent.userData.trailsOnMap[trailID].polyline.color = parent.userData.trailsOnMap[trailID].color
            parent.userData.trailsOnMap[trailID].polyline.trailID = trailID
            
            
            //loading trail images
            parent.dataStorage.loadTrailImages(trail: parent.userData.trailsOnMap[trailID])
            
            
            
            //draw trail on map
            parent.userModel.map.addOverlay(parent.userData.trailsOnMap[trailID].polyline)
            parent.userModel.map.addOverlay(parent.userData.trailsOnMap[trailID].polylineArrows)
            
            parent.userData.trailsOnMap[trailID].EndPin = TrailAnnotation(trailID: trailID,activityType: self.parent.userData.trailsOnMap[trailID].activityType)
            parent.userData.trailsOnMap[trailID].EndPin.coordinate = self.parent.userData.trailsOnMap[trailID].EndLocation
            parent.userData.trailsOnMap[trailID].EndPin.title = "finish"
            parent.userData.trailsOnMap[trailID].EndPin.annotationType = .TrailEndPoint
            self.parent.userModel.map.addAnnotation(parent.userData.trailsOnMap[trailID].EndPin)
            
            
            //WayPoints
            print("Selected annotation have \(parent.userData.trailsOnMap[trailID].WayPoints.count) WayPoints")
            if(parent.userData.trailsOnMap[trailID].WayPoints.count>0){
                //draw each waypoint
                for i in 0...parent.userData.trailsOnMap[trailID].WayPoints.count - 1 {
                    //print("Adding WayPoint Annotation \(parent.userData.trailsInArea[trailID].WayPoints[i].name)")
                    
                    parent.userData.trailsOnMap[trailID].WayPoints[i].annotation = WayPointAnnotation(trailID: trailID, wayPointID: parent.userData.trailsOnMap[trailID].WayPoints[i].id)
                    parent.userData.trailsOnMap[trailID].WayPoints[i].annotation.coordinate = parent.userData.trailsOnMap[trailID].WayPoints[i].coordonates.coordinate
                    parent.userData.trailsOnMap[trailID].WayPoints[i].annotation.title = parent.userData.trailsOnMap[trailID].WayPoints[i].name
                    parent.userData.trailsOnMap[trailID].WayPoints[i].annotation.annotationType = .WayPoint
                    self.parent.userModel.map.addAnnotation(parent.userData.trailsOnMap[trailID].WayPoints[i].annotation)
                    
                }
            }
        }
        
        //change start pin image
        if let annotationView = parent.userModel.map.view(for: parent.userData.trailsOnMap[trailID].StartPin) {
            annotationView.image = parent.getAnnotationImage(
                annotation: parent.userData.trailsOnMap[trailID].StartPin,
                isSelected: true
            )
        }
        
        
        print("selectedTrailID set \(trailID)")
        parent.userModel.annotationSelector.selectedTrailID = trailID
        parent.userModel.annotationSelector.isTrailSelected = true;
        print("selectedTrailID seteed to \(parent.userModel.annotationSelector.selectedTrailID)")
    }
    
    
    func deselectTrail(trailID:Int,forceDeselect:Bool = false){
        print("Deselecting trail")
        if trailID<0 {
            print("Wrong trailID \(trailID)")
            return
        }
        if parent.userData.trailsOnMap[trailID].isPinned && !forceDeselect{
            print("Trail is pinned, skip deselect")
            return
        }
        
        parent.userModel.map.removeOverlay(parent.userData.trailsOnMap[trailID].polyline)
        parent.userModel.map.removeOverlay(parent.userData.trailsOnMap[trailID].polylineArrows)
        parent.userModel.map.removeAnnotation(parent.userData.trailsOnMap[trailID].EndPin)
        
        //remove waypoints
        if(!parent.userData.trailsOnMap[trailID].WayPoints.isEmpty){
            for i in 0...parent.userData.trailsOnMap[trailID].WayPoints.count-1{
                parent.userModel.map.removeAnnotation(parent.userData.trailsOnMap[trailID].WayPoints[i].annotation)
            }
        }
              
         
        //change start pin image
        if let annotationView = parent.userModel.map.view(for: parent.userData.trailsOnMap[trailID].StartPin) {
            annotationView.image = parent.getAnnotationImage(
                annotation: parent.userData.trailsOnMap[trailID].StartPin,
                isSelected: false
            )
        }
    }
    
    
    
    
    func sheetTrailWasDismissed() {
        print("Coordinator: Trail sheet dismissed!")
        let trailID = parent.userModel.annotationSelector.selectedTrailID

        deselectTrail(trailID: trailID)
        
        parent.userModel.map.deselectAnnotation(parent.userData.trailsOnMap[trailID].StartPin, animated: true)
     
       

    }
    
    
    func sheetWayPointWasDismissed(){
        print("Coordinator: Waypoint sheet dismissed!")
        let trailID = parent.userModel.annotationSelector.selectedTrailID
        
        parent.userModel.map.deselectAnnotation(parent.userData.trailsOnMap[trailID].WayPoints.first(where: {$0.id == parent.userModel.annotationSelector.selectedWayPointID})?.annotation, animated: true)
     
        
        
        
    }
    
    
    func trailColorChangedAction(){
        print("Coordinator: Trail Color Changed!")
        let trailID = parent.userModel.annotationSelector.selectedTrailID
        
        DispatchQueue.main.async { [weak self] in
              guard let self = self else { return }
              deselectTrail(trailID: trailID,forceDeselect: true)
              selectTrail(trailID: trailID, forceSelect: true)
          }
    }
    
    
    
    

    
    @objc func didLongTapMap(_ sender: UITapGestureRecognizer) {
            print("Did long tap on map")
        
        
        let map = parent.userModel.map
        let point = sender.location(in: map)
        let coordinate = map.convert(point, toCoordinateFrom: map)

       
        var tappedOnAnnotation = false
        
        // Check if tap is on an annotation
        for annotation in map.annotations {
            let annotationView = map.view(for: annotation)
            if let view = annotationView {
                let frame = view.frame.insetBy(dx: -10, dy: -10) // tolerance
                if frame.contains(point) {
                    print("Tapped on annotation – do NOT create temp mark")
                    tappedOnAnnotation = true
                }
            }
        }
        
        
        if !tappedOnAnnotation {
            addTempAnnotation(at: coordinate)
            //            let generator = UIImpactFeedbackGenerator(style: .medium)
            //            generator.prepare()
            //            generator.impactOccurred()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
    }
    
    // Tapping on map
    @objc func didTapMap(_ sender: UITapGestureRecognizer) {
        print("Tap on map")

        
        let map = parent.userModel.map
        let point = sender.location(in: map)
        let coordinate = map.convert(point, toCoordinateFrom: map)

        var tappedOnTrail = false
        var tappedOnAnnotation = false
        
        
        // Check if type on polyline
        for overlay in map.overlays {
            guard let polyline = overlay as? MyCustomPolyline else { continue }

            if isCoordinate(coordinate, nearPolyline: polyline, tolerance: 10, in: map) {
                print("Polyline tapped!")
           
                print(polyline.trailID)
                if let trailID = polyline.trailID{
                    
                    //deselect previous
                    let prevSelectedTrailID = parent.userModel.annotationSelector.selectedTrailID
                    if(prevSelectedTrailID >= 0  && prevSelectedTrailID != trailID){
                        deselectTrail(trailID: prevSelectedTrailID)
                    }
                    
                    print("taponmap: settings selectedTrailID \(trailID)")
                    parent.userModel.annotationSelector.selectedTrailID = trailID
                    parent.userModel.annotationSelector.isTrailSelected = true;
                }
                tappedOnTrail  = true
                break
            }
        }
        
        
//        // Check if tap is on an annotation
//        for annotation in map.annotations {
//            let annotationView = map.view(for: annotation)
//            if let view = annotationView {
//                let frame = view.frame.insetBy(dx: -10, dy: -10) // tolerance
//                if frame.contains(point) {
//                    print("Tapped on annotation – do NOT create temp mark")
//                    tappedOnAnnotation = true
//                }
//            }
//        }
//        
//        
//        if !tappedOnTrail && !tappedOnAnnotation {
//            addTempAnnotation(at: coordinate)
//        }
        
//        if parent.userModel.annotationSelector.isWayPointSelected{
//            
//            parent.userModel.map.deselectAnnotation(parent.userData.trailsInArea[parent.userModel.annotationSelector.selectedTrailID].WayPoints.first(where: {$0.id == parent.userModel.annotationSelector.selectedWayPointID})?.annotation, animated: true)
//            parent.userModel.annotationSelector.isWayPointSelected  = false
//        }
//        if(!tappedOnTrail){
//            // when click anywhere on map, if trail is selected - deselect it
//            print("Tapped outside of trail")
//            print("Is trail selected: \(parent.userModel.annotationSelector.isTrailSelected)")
//            
//            // if is Waypoint selected, close only WayPoint
//            // if is Trail selected, close trail
//            if(parent.userModel.annotationSelector.isWayPointSelected){
//                parent.userModel.annotationSelector.isWayPointSelected = false;
//            }else
//            if(parent.userModel.annotationSelector.isTrailSelected){
//                //parent.userModel.annotationSelector.isTrailSelected = false;
//                
//                DispatchQueue.main.async {[self] in
//                    parent.userModel.annotationSelector.isTrailSelected = false
//                }
//                
//                
//                if(!parent.userData.trailsInArea[parent.userModel.annotationSelector.selectedTrailID].isPinned){
//                    print("Deselect trail on tap ")
//                    deselectTrail(trailID: parent.userModel.annotationSelector.selectedTrailID)
//                    print("Deselect trail on tap Done")
//                }
//            }
//            
//        }
        
    }
    
    
    func addTempAnnotation(at coordinate: CLLocationCoordinate2D) {


        // Create new annotation
        let annotation = TemporaryAnotation(annotationType: .TempPin)
        annotation.coordinate = coordinate
        annotation.title = "Pin"

        // Save reference
        tempAnnotations.append(annotation)

        // Add to map
        parent.userModel.map.addAnnotation(annotation)

        print("Added temp annotation at \(coordinate.latitude), \(coordinate.longitude)")
    }

    
    
    //select annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Select Annotation");
      //  guard let selectedAnnotation = view.annotation as? TrailAnnotation else{return}
       
        
        if let selectedAnnotation = (view.annotation as? TrailAnnotation){
            if((selectedAnnotation as TrailAnnotation).annotationType == .TrailStartPoint) {
                guard selectedAnnotation.trailID<parent.userData.trailsOnMap.count else{return}
                let prevSelectedTrailID = parent.userModel.annotationSelector.selectedTrailID
                print("Trail StartPoint Selected")
                    
                print("previous selected trail \(prevSelectedTrailID)")
                //deselect previous
                deselectTrail(trailID: prevSelectedTrailID)
                     
                
//                //change annotation image when select
//                view.image  = parent.getAnnotationImage(annotation: selectedAnnotation, isSelected: true)
                    
                
                selectTrail(trailID: selectedAnnotation.trailID)
                
            } //TrailStartPoint select end
        }
        
        
        if let selectedAnnotation = (view.annotation as? WayPointAnnotation){
            if(selectedAnnotation.annotationType == .WayPoint) {
                print("Selected WayPoint:  trailID \(selectedAnnotation.trailID), wayPointID: \(selectedAnnotation.wayPointID)")
                
                //change annotation image when select
                view.image  = parent.getAnnotationImage(annotation: selectedAnnotation,isSelected: true)
                
                
                if selectedAnnotation.trailID>=0{
                    print("wp selectedTrailID set to \(selectedAnnotation.trailID)")
                    parent.userModel.annotationSelector.selectedTrailID = selectedAnnotation.trailID
                    parent.userModel.annotationSelector.selectedWayPointID = selectedAnnotation.wayPointID
                    parent.userModel.annotationSelector.isWayPointSelected = true;
                } else{
                    parent.userModel.annotationSelector.iscurrTrailWayPointSelected = true
                    parent.userModel.annotationSelector.selectedCurrTrailWayPointID = selectedAnnotation.wayPointID
                }
             
            }
        }
        
        if let selectedAnnotation = (view.annotation as? TemporaryAnotation){
                print("Temporarry anotation selected")
                guard let index = tempAnnotations.firstIndex(where: { $0.id == selectedAnnotation.id }) else {
                    print("TempAnnotation not found in array")
                    return
                }
            
                parent.userModel.map.removeAnnotation(tempAnnotations[index])
              
                
        }
        
    }
    
    
    //deSelect annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //guard let deseletectedAnnotation = view.annotation as? MyCustomPointAnnotation else{return}

//            print("Manual Deselect")
//            if let deseletectedAnnotation = (view.annotation as? TrailAnnotation){
//                guard deseletectedAnnotation.trailID<parent.userData.trailsInArea.count else{print("invalid trailID");return}
//                let trailID = deseletectedAnnotation.trailID
//                print("Deselect Trail with trailID \(deseletectedAnnotation.trailID)");
//                //change annotation image when select
//                view.image  = parent.getAnnotationImage(annotation: deseletectedAnnotation,isSelected: false)
//             
//                
//            }
            
            
            if let deselectedAnnotation = (view.annotation as? WayPointAnnotation){
                if(deselectedAnnotation.annotationType == .WayPoint) {
                    print("deSelected WayPoint:  trailID \(deselectedAnnotation.trailID), wayPointID: \(deselectedAnnotation.wayPointID)")
                    //change annotation image when select
                    view.image  = parent.getAnnotationImage(annotation: deselectedAnnotation, isSelected: false)
//                    parent.userModel.annotationSelector.isWayPointSelected = false;
                    
                    
                }
            }

    }
    
    
    //mapView update location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //   print("mapView: didUpdate")
        
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //print(" finish loading map ")
    }
    
    
    @MainActor func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print(" finish rendering map ")
        guard parent.userModel.coordinateBottomLeft != nil else {return}
        guard parent.userModel.coordinateTopRight != nil else {return}
        guard parent.userModel.region != nil else {return}
        
        //loading trails in area
        if(!parent.userData.trailsInAreaisLoading) && (parent.userModel.recordingStatus != .isStarted){ //load trail if not another load task is started, or not recording trail now
          
                //start loading from server
                print("start loading from server")
            
                //check if area is not too big
                let distance = parent.userModel.coordinateBottomLeft!.distance(to: parent.userModel.coordinateTopRight!)
                print("Distance: \(distance)")
            
                if(distance > 269516 || distance == 0.0){
                    print("Too big area for refreshing")
                    parent.userModel.searchAreTooBig = true
                    return;
                }else{
                    parent.userModel.searchAreTooBig = false
                }
            
               // parent.userData.db_GetCurrentAreaTrails(btLeft: parent.userModel.coordinateBottomLeft,tpRight: parent.userModel.coordinateTopRight)
                parent.userData.db_GetCurrentAreaTrailsNew(region: parent.userModel.region!)
            //wait while complete
              //  print("wait while complete")
              //  while(parent.userData.loadingTrails){}
                
                //draw to map
             //   print("draw to map \(parent.userData.trailsLoaded.count)")
             //   parent.userModel.DrawTrailsInArea(trails: &parent.userData.trailsLoaded)
            
        }
        
        
    }
    
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
  
        self.parent.userModel.region = mapView.region
        self.parent.userModel.coordinateBottomLeft = CLLocationCoordinate2D(
            latitude: mapView.centerCoordinate.latitude - (mapView.region.span.latitudeDelta / 2),
            longitude: mapView.centerCoordinate.longitude - (mapView.region.span.longitudeDelta / 2))
        
        self.parent.userModel.coordinateTopRight = CLLocationCoordinate2D(
            latitude: mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta / 2),
            longitude: mapView.centerCoordinate.longitude + (mapView.region.span.longitudeDelta / 2))
        
        
    }
    
    
    
}
    
    

