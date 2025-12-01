//
//  FirestoreMigration.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 29.11.2025.
//

//class GeohashMigrationService {
//
//    let db = Firestore.firestore()
//
//    /// Update all Trails to correct string geohash format
//    func migrateGeohashes(completion: @escaping () -> Void) {
//        print("Starting geohash migration…")
//
//        db.collectionGroup("Trails").getDocuments { snapshot, error in
//            if let error = error {
//                print("❌ Error fetching trails: \(error)")
//                completion()
//                return
//            }
//
//            guard let docs = snapshot?.documents else {
//                print("❌ No Trails found.")
//                completion()
//                return
//            }
//
//            print("Found \(docs.count) Trails to update.")
//
//            let group = DispatchGroup()
//
//            for doc in docs {
//                let data = doc.data()
//                let lat = data["Start Location latitude"] as? Double ?? 0
//                let lng = data["Start Location longitude"] as? Double ?? 0
//
//                // Skip invalid coordinates
//                if lat == 0 && lng == 0 { continue }
//
//                let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//                //let geohash = GFUtils.geoHash(forLocation: location)
//                let hash = GFGeoHash(location: CLLocationCoordinate2D(latitude: lat, longitude: lng))
//                let geohash = hash?.geoHashValue ?? ""
//                
//                group.enter()
//
//                doc.reference.updateData([
//                    "geohash": geohash
//                ]) { error in
//                    if let error = error {
//                        print("❌ Error updating doc \(doc.documentID): \(error)")
//                    } else {
//                        print("✔ Updated geohash for \(doc.documentID)")
//                    }
//                    group.leave()
//                }
//            }
//
//            group.notify(queue: .main) {
//                print("🎉 Geohash migration finished!")
//                completion()
//            }
//        }
//    }
//}
