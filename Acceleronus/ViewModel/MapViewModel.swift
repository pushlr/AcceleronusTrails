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
        
            return userModel.map
        }

    
        func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        //    print("updateUIView")
//            uiView.removeAnnotations(uiView.annotations)
//
//            for mapItem in mapItems {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = mapItem.placemark.coordinate
//                annotation.title = mapItem.name
//                uiView.addAnnotation(annotation)
//            }

//            if let firstMapItem = mapItems.first {
//                let region = MKCoordinateRegion(
//                    center: firstMapItem.placemark.coordinate,
//                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//                )
//                uiView.setRegion(region, animated: true)
//                mapItems.removeAll()
//            }
            
        }
    
    
        func makeCoordinator() -> MapCoordinator {
            Coordinator(self)
        }
    
    
    func getAnnotationImage(annotation: BaseAnnotation, isSelected : Bool = false) -> UIImage? {
        
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
                    .roundedImageWithBorder(width: 3, color: isSelected ? UIColor.orange : UIColor.brown)
                
            case .TrailEndPoint:
                return UIImage(named: "finish")?
                  //  .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 3, color: isSelected ? UIColor.orange : UIColor.brown)
                
                
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
                    .roundedImageWithBorder(width: 2, color: UIColor.orange)
                 :
                UIImage(named: "waypoint")?
                    .resizeImageTo(size: CGSize(width: 20, height: 20))?
                   // .withBackground(color: UIColor.white)
                    .roundedImageWithBorder(width: 2, color: UIColor.brown)
                   
                
             }
        }
    

}
    

    


class MapCoordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var parent: MapView
    
    
    init(_ parent: MapView) {
        self.parent = parent
        super.init()
        parent.userModel.locationManager.delegate = self
        parent.userModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        parent.userModel.locationManager.requestWhenInUseAuthorization()
        parent.userModel.locationManager.allowsBackgroundLocationUpdates = true
        //parent.userModel.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        //parent.userModel.locationManager.distanceFilter = 100
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
        print("LocationManager : didUpdateLocations")
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
        
        
        //is good location?
        if(parent.userModel.trailRecorded.coordinateRecorded.count>=1){
            if(parent.userModel.trailRecorded.coordinateRecorded[parent.userModel.trailRecorded.coordinateRecorded.endIndex-1]
                .distance(to:parent.userModel.lastLocation.coordinate)>5){
                print("isGoodLocation")
            }else
            {
                print("isNotGoodLocation")
                return
            }
        }
        
        //is good GPS signal
        if(parent.userModel.lastGPSStrenght>20){
            print("low GPS Signal : \(parent.userModel.lastGPSStrenght)")
            return
        }
        
        if(parent.userModel.recordingStatus == RecordingStatus.isStarted){
            
            
         
            
            
            //store coordinates
            parent.userModel.trailRecorded.coordinateRecorded.insert(location.coordinate, at: parent.userModel.trailRecorded.coordinateRecorded.endIndex)
            
            //draw lines
            parent.userModel.drawPolyline(trail: &parent.userModel.trailRecorded)
//            parent.userModel.map.removeOverlay(parent.userModel.trailRecorded.polyline)
//            parent.userModel.trailRecorded.polyline =
//            MyCustomPolyline(coordinates: parent.userModel.trailRecorded.coordinateRecorded,
//                             count: parent.userModel.trailRecorded.coordinateRecorded.count)
//            parent.userModel.trailRecorded.polyline.color = UIColor(parent.userModel.trailRecordedSettings.lineColor)
//            parent.userModel.map.addOverlay(parent.userModel.trailRecorded.polyline)
            
            
            
            //add Start place
            if(parent.userModel.trailRecorded.coordinateRecorded.count==1){
                parent.userModel.drawStartLocation()
//                parent.userModel.trailRecorded.StartPin = TrailAnnotation(trailID: 0, activityType: self.parent.userModel.trailRecorded.activityType)
//                parent.userModel.trailRecorded.StartPin.coordinate = self.parent.userModel.trailRecorded.StartLocation
//                parent.userModel.trailRecorded.StartPin.title = "Start Point".localized
//                parent.userModel.trailRecorded.StartPin.annotationType = AnnotationType.StartRecording
//                
//                parent.userModel.map.addAnnotation(parent.userModel.trailRecorded.StartPin)
                
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
    
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MyCustomPolyline {
//            print("rendering...")
////            let renderer = MKPolylineRenderer(polyline: overlay as! MyCustomPolyline )
////            renderer.strokeColor = .red
////            renderer.lineWidth = 6
//            let customRenderer = CustomPolylineRenderer(overlay: overlay as! MyCustomPolyline)
//          
//            return customRenderer
//        }
//        return MKOverlayRenderer(overlay: overlay)
//    }
//    
    
    
    
    
    
//
//    class Callout: UIView {
//      private let titleLabel = UILabel(frame: .zero)
//      private let subtitleLabel = UILabel(frame: .zero)
//    
//   //   private let imageView = UIImageView(frame: .zero)
//      private let annotation: FriendTrailAnnotation
//      private let DisplayName : String
//    
//        
//        init(annotation: FriendTrailAnnotation, DisplayName: String) {
//            self.annotation = annotation
//            self.DisplayName = DisplayName
//          
//            super.init(frame: .zero)
//            setupView()
//      }
//      
//      required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//      }
//      
//      private func setupView() {
//        translatesAutoresizingMaskIntoConstraints = false
//        setupTitle()
//        setupSubtitle()
//     //   setupImageView()
//      }
//      
//      private func setupTitle() {
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        titleLabel.text = DisplayName
//        addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//      }
//      
//      private func setupSubtitle() {
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
//        subtitleLabel.textColor = .gray
//        subtitleLabel.text = "trail.TotalTimeFormatted"
//        addSubview(subtitleLabel)
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
//        subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        subtitleLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        subtitleLabel.widthAnchor.constraint(equalToConstant: 280).isActive = true
//      }
//      
////      private func setupImageView() {
////        imageView.image = UIImage(named: "Image 1")//"annotation.image"
////        imageView.contentMode = .scaleAspectFill
////        imageView.clipsToBounds = true
////        addSubview(imageView)
////        imageView.translatesAutoresizingMaskIntoConstraints = false
////        imageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8).isActive = true
////        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
////        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
////        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
////        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
////        imageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
////      }
//    }
    
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
            
            //Waypoint title, currentRecorded trail or trailsInArea ?
//            if(myannotation.trailID>=0){
//                view.title = parent.userData.trailsInArea[myannotation.trailID].WayPoints.first(where: {$0.id == myannotation.wayPointID})?.name ?? "unknown"
//            } else{
//                view.title = parent.userModel.trailRecorded.WayPoints.first(where: {$0.id == myannotation.wayPointID})?.name ?? "unknown"
//            }
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
    
        
        print("FATAL: Nill Annotation")
        return nil
    }
    
    

           
           
    
    //select annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Select Annotation");
      //  guard let selectedAnnotation = view.annotation as? TrailAnnotation else{return}
        
        
        if let selectedAnnotation = (view.annotation as? TrailAnnotation){
            if((selectedAnnotation as TrailAnnotation).annotationType == .TrailStartPoint) {
            guard selectedAnnotation.trailID<parent.userData.trailsInArea.count else{return}
            print("Trail StartPoint Selected")
                
            //change annotation image when select
                view.image  = parent.getAnnotationImage(annotation: selectedAnnotation, isSelected: true)
                
            
            //draw polylines if not already exist
            if(!parent.userData.trailsInArea[selectedAnnotation.trailID].isPinned) && (!parent.userModel.selectTrailAfterWaypointDeselect){
                //Draw poliline for selected trail
                parent.userData.trailsInArea[selectedAnnotation.trailID].polyline =
                MyCustomPolyline(coordinates: parent.userData.trailsInArea[selectedAnnotation.trailID].coordinateRecorded, count: parent.userData.trailsInArea[selectedAnnotation.trailID].coordinateRecorded.count)
                //Draw polyline arrwows
                parent.userData.trailsInArea[selectedAnnotation.trailID].polylineArrows =
                MyCustomPolylineArrows(coordinates: parent.userData.trailsInArea[selectedAnnotation.trailID].coordinateRecorded, count: parent.userData.trailsInArea[selectedAnnotation.trailID].coordinateRecorded.count)
                
                parent.userData.trailsInArea[selectedAnnotation.trailID].polyline.color = UIColor.orange
                parent.userModel.map.addOverlay(parent.userData.trailsInArea[selectedAnnotation.trailID].polyline)
                parent.userModel.map.addOverlay(parent.userData.trailsInArea[selectedAnnotation.trailID].polylineArrows)
                
                
                //add end point for selected trail
                let idx = selectedAnnotation.trailID
                
                parent.userData.trailsInArea[idx].EndPin = TrailAnnotation(trailID: 0,activityType: self.parent.userData.trailsInArea[idx].activityType)
                parent.userData.trailsInArea[idx].EndPin.coordinate = self.parent.userData.trailsInArea[idx].EndLocation
                parent.userData.trailsInArea[idx].EndPin.title = "finish"
                parent.userData.trailsInArea[idx].EndPin.annotationType = .TrailEndPoint
                self.parent.userModel.map.addAnnotation(parent.userData.trailsInArea[idx].EndPin)
                
                
                //WayPoints
                print("Selected annotation have \(parent.userData.trailsInArea[idx].WayPoints.count) WayPoints")
                if(parent.userData.trailsInArea[idx].WayPoints.count>0){
                    //draw each waypoint
                    for i in 0...parent.userData.trailsInArea[idx].WayPoints.count - 1 {
                        print("Adding WayPoint Annotation \(parent.userData.trailsInArea[idx].WayPoints[i].name)")
                        
                        parent.userData.trailsInArea[idx].WayPoints[i].annotation = WayPointAnnotation(trailID: idx, wayPointID: parent.userData.trailsInArea[idx].WayPoints[i].id)
                        parent.userData.trailsInArea[idx].WayPoints[i].annotation.coordinate = parent.userData.trailsInArea[idx].WayPoints[i].coordonates.coordinate
                        parent.userData.trailsInArea[idx].WayPoints[i].annotation.title = parent.userData.trailsInArea[idx].WayPoints[i].name
                        parent.userData.trailsInArea[idx].WayPoints[i].annotation.annotationType = .WayPoint
                        self.parent.userModel.map.addAnnotation(parent.userData.trailsInArea[idx].WayPoints[i].annotation)
                        
                    }
                }
            }
            
            print("setting AnnotationSelected to true")
            parent.dataStorage.loadTrailImages(trail: parent.userData.trailsInArea[selectedAnnotation.trailID])
                
                
            parent.userModel.annotationSelector.selectedTrailID = selectedAnnotation.trailID
            parent.userModel.annotationSelector.isTrailSelected = true;
                
        } //TrailStartPoint select end
    }
        
        
        if let selectedAnnotation = (view.annotation as? WayPointAnnotation){
            if(selectedAnnotation.annotationType == .WayPoint) {
                print("Selected WayPoint:  trailID \(selectedAnnotation.trailID), wayPointID: \(selectedAnnotation.wayPointID)")
                
                
                //change annotation image when select
                view.image  = parent.getAnnotationImage(annotation: selectedAnnotation,isSelected: true)
        
                parent.userModel.annotationSelector.selectedTrailID = selectedAnnotation.trailID
                parent.userModel.annotationSelector.selectedWayPointID = selectedAnnotation.wayPointID
                parent.userModel.annotationSelector.isWayPointSelected = true;
                
                if (selectedAnnotation.trailID>=0 && selectedAnnotation.trailID < parent.userData.trailsInArea.count){
                    //parent.userData.trailsInArea[selectedAnnotation.trailID].isPinned = true
                    parent.userModel.selectTrailAfterWaypointDeselect = true
                }
                
            }
        }
        
    }
    
    
    //deSelect annotation
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        //guard let deseletectedAnnotation = view.annotation as? MyCustomPointAnnotation else{return}
        
     
            if let deseletectedAnnotation = (view.annotation as? TrailAnnotation){
                guard deseletectedAnnotation.trailID<parent.userData.trailsInArea.count else{return}
                let trailID = deseletectedAnnotation.trailID
                print("Deselect Trail with trailID \(deseletectedAnnotation.trailID)");
                //set selected to false
                parent.userModel.annotationSelector.isTrailSelected = false;
                
                let secondsToDelay = 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) { [self] in
                    //deselect trail if is not pinned
                    if(!parent.userData.trailsInArea[trailID].isPinned) && (!parent.userModel.selectTrailAfterWaypointDeselect){
                        parent.userModel.map.removeOverlay(parent.userData.trailsInArea[trailID].polyline)
                        parent.userModel.map.removeOverlay(parent.userData.trailsInArea[trailID].polylineArrows)
                        parent.userModel.map.removeAnnotation(parent.userData.trailsInArea[trailID].EndPin)
                        
                        //remove waypoints
                        if(!parent.userData.trailsInArea[trailID].WayPoints.isEmpty){
                            for i in 0...parent.userData.trailsInArea[trailID].WayPoints.count-1{
                                parent.userModel.map.removeAnnotation(parent.userData.trailsInArea[trailID].WayPoints[i].annotation)
                            }
                        }
                        
                        //change annotation image when select
                        view.image  = parent.getAnnotationImage(annotation: deseletectedAnnotation,isSelected: false)
                        
                    }
                  
                }
            }
            
            
            
            if let deselectedAnnotation = (view.annotation as? WayPointAnnotation){
                if(deselectedAnnotation.annotationType == .WayPoint) {
                    print("deSelected WayPoint:  trailID \(deselectedAnnotation.trailID), wayPointID: \(deselectedAnnotation.wayPointID)")
                    //change annotation image when select
                    view.image  = parent.getAnnotationImage(annotation: deselectedAnnotation, isSelected: false)
                    
                    parent.userModel.annotationSelector.isWayPointSelected = false;
                    
                    //need to show trail sheet back ?
                    if (parent.userModel.selectTrailAfterWaypointDeselect) && (deselectedAnnotation.trailID>=0 && deselectedAnnotation.trailID < parent.userData.trailsInArea.count){
                        //if not another waypoint selected then select the trail
                        let secondsToDelay = 0.1
                        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) { [self] in
                            if(!parent.userModel.annotationSelector.isWayPointSelected){
                                parent.userModel.map.selectAnnotation(parent.userData.trailsInArea[deselectedAnnotation.trailID].StartPin, animated: true)
                                parent.userModel.selectTrailAfterWaypointDeselect = false
                            }
                        }
                    }
                    
                }
            }
            
      //  }
    }
    
    
    //mapView update location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //   print("mapView: didUpdate")
        
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print(" finish loading map ")
    }
    
    
    @MainActor func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print(" finish rendering map ")
        guard parent.userModel.coordinateBottomLeft != nil else {return}
        guard parent.userModel.coordinateTopRight != nil else {return}
        
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
            
                parent.userData.db_GetCurrentAreaTrails(btLeft: parent.userModel.coordinateBottomLeft,
                                                        tpRight: parent.userModel.coordinateTopRight)
                //wait while complete
              //  print("wait while complete")
              //  while(parent.userData.loadingTrails){}
                
                //draw to map
             //   print("draw to map \(parent.userData.trailsLoaded.count)")
             //   parent.userModel.DrawTrailsInArea(trails: &parent.userData.trailsLoaded)
            
        }
        
        
    }
    
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
       
        self.parent.userModel.coordinateBottomLeft = CLLocationCoordinate2D(
            latitude: mapView.centerCoordinate.latitude - (mapView.region.span.latitudeDelta / 2),
            longitude: mapView.centerCoordinate.longitude - (mapView.region.span.longitudeDelta / 2))
        
        self.parent.userModel.coordinateTopRight = CLLocationCoordinate2D(
            latitude: mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta / 2),
            longitude: mapView.centerCoordinate.longitude + (mapView.region.span.longitudeDelta / 2))
        
        
    }
    
    
    
}
    
    

