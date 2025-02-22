//
//  DataStorage.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 01.12.2023.
//

import Foundation
import SwiftUI
import FirebaseStorage

struct UploadFile{
    var localPath  : String
    var remotePath : String
    
}

class UploadManager {
    let storage = Storage.storage()
    
    
    func doWork(){
        var worksCount = UserDefaults.standard.integer(forKey: "UploadManager_WorksCount")
        print("Upload unfinished works count : \(worksCount)")
        guard worksCount > 0 else {return}
        var isDir : ObjCBool = false
        
        for i in 0...worksCount - 1 {
            let wd = "UploadManager_File\(i)_workDir"
            let fn = "UploadManager_File\(i)_fileName"
            let rp = "UploadManager_File\(i)_remotePath"
           
            let workDir =  UserDefaults.standard.string(forKey: wd) ?? ""
            let fileName =  UserDefaults.standard.string(forKey: fn) ?? ""
            let remotePath = URL(string: UserDefaults.standard.string(forKey: rp) ?? "/")!
            
            let localPath = FileManager.default.documentDirectory.appending(path: workDir).appending(path: fileName)
            
            isDir = false 
            if (!FileManager.default.fileExists(atPath: localPath.path(),isDirectory: &isDir)) || (isDir.boolValue) {
                print("Upload task not valid: \(localPath)")
                UserDefaults.standard.removeObject(forKey: wd)
                UserDefaults.standard.removeObject(forKey: fn)
                UserDefaults.standard.removeObject(forKey: rp)
                worksCount -= 1
                UserDefaults.standard.set(worksCount, forKey: "UploadManager_WorksCount")
                continue
            }
            
            print("uploading file \(localPath) to \(remotePath)")
            let storageRef = storage.reference(withPath: remotePath.path())
            let uploadTask = storageRef.putFile(from: localPath)
                        
            uploadTask.observe(.success) { snapshot in
                print("upload Successfully")
                UserDefaults.standard.removeObject(forKey: wd)
                UserDefaults.standard.removeObject(forKey: fn)
                UserDefaults.standard.removeObject(forKey: rp)
                worksCount -= 1
                UserDefaults.standard.set(worksCount, forKey: "UploadManager_WorksCount")
                               
            }
            
            
            
            
                // Listen for state changes, errors, and completion of the upload.
                uploadTask.observe(.resume) { snapshot in
                    // Upload resumed, also fires when the upload starts
                }
    
                uploadTask.observe(.pause) { snapshot in
                    // Upload paused
                }
    
                uploadTask.observe(.progress) { snapshot in
                    // Upload reported progress
    
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                    print("upload progress: \(percentComplete)")
                }
    
  
    
    
                uploadTask.observe(.failure) { snapshot in
                    if let error = snapshot.error as? NSError {
                        switch (StorageErrorCode(rawValue: error.code)!) {
                        case .objectNotFound:
                            // File doesn't exist
                            print("Upload Error: objectNotFound")
                            break
                        case .unauthorized:
                            // User doesn't have permission to access file
                            print("Upload Error: unauthorized")
                            break
                        case .cancelled:
                            // User canceled the upload
                            print("Upload Error: cancelled")
                            break
    
                            /* ... */
    
                        case .unknown:
                            // Unknown error occurred, inspect the server response
                            print("Upload Error: unknown")
                            print(error)
                            break
                        default:
                            // A separate error occurred. This is a good place to retry the upload.
                            print("Upload Error: default")
                            break
                        }
                    }
                }
            
            
            
            
            
            
            
            
            
            
        }
    }
 
    
}

class DataStorage : ObservableObject {
    @Published var storages : [DataStorageItem] = []
    var uploadManager = UploadManager()
    
    private func createStorage(workDir: String, id : String ) -> Bool  {
        let newStorage = DataStorageItem(id: id, workDir: workDir, willUpdateData: self.willChange)
        objectWillChange.send()
        storages.append(newStorage)
        return true
    }
    
    func willChange(){
        //one of storage changed
        objectWillChange.send()
    }
    //readonly
    func getStorage(_ storageID: String) -> DataStorageItem?{
        return self.storages.first(where: {$0.id == storageID})
    }
    func getStorage(_ storageID: UUID) -> DataStorageItem?{
        return self.storages.first(where: {$0.id == storageID.uuidString})
    }
    
    //binding
    func getStorageBinding(_ storageID: String) -> Binding<DataStorageItem>? {
        for i in 0...storages.count-1{
            if storages[i].id == storageID {
                return Binding(get: {self.storages[i]}, set: {self.storages[i] = $0})
            }
        }
        return nil
    }
    
    
    
    // STORAGE INITIALIZATORS
    
//    func createStorageFor(_ friends: [FriendInfo]){
//        print("initStorageForFriends count: \(friends.count)")
//        if(friends.isEmpty){return}
//        for i in 0...friends.count-1{
//            if(getStorage(friends[i].userID) == nil){
//                print("creating Storage AccountImages/" + friends[i].userID)
//                createStorage(workDir: "AccountImages/" + friends[i].userID, id: friends[i].userID)
//            }
//        }
//    }
  
    func createStorageFor(_ friends: FriendInfo){
        print("initStorageForFriends count: \(friends.DisplayName)")
      //  if(friends.isEmpty){return}
      //  for i in 0...friends.count-1{
            if(getStorage(friends.userID) == nil){
                print("creating Storage AccountImages/" + friends.userID)
                createStorage(workDir: "AccountImages/" + friends.userID, id: friends.userID)
            }
       // }
    }
    
    func createStorageFor(_ trail : Trail){
        if(getStorage(trail.id) == nil){
            createStorage(workDir: "TrailsImages/" + trail.id.uuidString, id: trail.id.uuidString)
        }
    }
    
    func createStorageFor(_ wayPoint : WayPoint, trail: Trail){
        if(getStorage(wayPoint.id) == nil){
            createStorage(workDir: "TrailsImages/" + trail.id.uuidString, id: wayPoint.id.uuidString)
        }
    }
    
    func createStorageFor(_ userData : UserData){
        if(getStorage(userData.userID) == nil){
            createStorage(workDir: "AccountImages/" + userData.userID, id: userData.userID)
        }
    }
    
    
    func loadTrailImages(trail : Trail){
        createStorageFor(trail)
        
        //LOAD WAYPOINTS IMAGE FIRST
        print("Loading waypoint")
        //WAYPOINT IMAGES
        if(!trail.WayPoints.isEmpty){
            for i in 0...trail.WayPoints.count-1{
                createStorageFor(trail.WayPoints[i], trail: trail)
                getStorage(trail.WayPoints[i].id)!.addItems(trail.WayPoints[i].images)
                //add to trails images also, for trail preview
                getStorage(trail.id)!.addItems(trail.WayPoints[i].images)
            }
        }
        
        
        //LOAD TRAIL IMAGES
        getStorage(trail.id)!.addItems(trail.images)
       
    }

    
    func removeTrailImages(trail : Trail){
        createStorageFor(trail)
        getStorage(trail.id)!.addItems(trail.images, downloadAllowed: false)
        
        if(!trail.WayPoints.isEmpty){
            for i in 0...trail.WayPoints.count-1{
                getStorage(trail.id)!.addItems(trail.WayPoints[i].images,downloadAllowed: false)
            }
        }
        
        getStorage(trail.id)!.deleteWorkDir()
        
        
    }
    
    func uploadTrailImages(trail : Trail){
        getStorage(trail.id)?.uploadToCloud()
        if(!trail.WayPoints.isEmpty){
            for i in 0...trail.WayPoints.count-1{
                getStorage(trail.WayPoints[i].id)?.uploadToCloud()
            }
        }
        
        uploadManager.doWork()
    }
   
    
    func uploadStorage(storageID : String ){
        getStorage(storageID)?.uploadToCloud()
        uploadManager.doWork()
    }

 
    
    
}

