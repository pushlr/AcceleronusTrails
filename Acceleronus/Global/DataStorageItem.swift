//
//  DataStorageItem.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 01.12.2023.
//

import Foundation
import FirebaseStorage
import SwiftUI




class DataStorageItem: ObservableObject,Identifiable {
    var id : String
    @Published var items: [DataItem] = []
    var willUpdateData : () -> ()
    
    let storage = Storage.storage()
 
    var workingDirRaw : String
    var workingDirectory : URL
    var workingDirectoryServer : URL
    var downloadTasks = [StorageDownloadTask]()
    
    init(id: String, workDir: String, willUpdateData: @escaping () -> ()){
        self.id = id
        workingDirRaw = workDir
        workingDirectory = FileManager.default.documentDirectory.appending(path: workDir)
        workingDirectoryServer = URL(string: workDir)!
        self.willUpdateData = willUpdateData
    }
    
    func ChangeWorkDir(workDir: String){
        workingDirectory = FileManager.default.documentDirectory.appending(path: workDir)
        workingDirectoryServer = URL(string: workDir)!
    }

    func deleteWorkDir(){ //deleting all photos from localstorage and remote storage
        print("deleteWorkDir")
        //delete local diretory
        if FileManager.default.fileExists(atPath: workingDirectory.path){
            do {
                try FileManager.default.removeItem(atPath: workingDirectory.path)
            } catch {
                print(error)
            }
        } else {print("workDir not created")}
        
        //delete remote photos
        let storageRef = storage.reference(withPath: workingDirectoryServer.path)
        
        storageRef.listAll { (result, error) in
          if let error = error {
            return
          }
         for item in result!.items {
          Task{
             try await item.delete()
          }
         }
        }
        
    }
    
    
    func uploadToCloud(){
        guard !items.isEmpty else {return}
        var worksCount = UserDefaults.standard.integer(forKey: "UploadManager_WorksCount")
        
        for i in 0...items.count-1{
            print("preparing file \(items[i].name) for upload")
            let wd = "UploadManager_File\(i+worksCount)_workDir"
            let fn = "UploadManager_File\(i+worksCount)_fileName"
            let rp = "UploadManager_File\(i+worksCount)_remotePath"
            
            let remotePath =  workingDirectoryServer.appending(path: items[i].name)
                        
            print("setting \(items[i].name) from \(workingDirectory) to \(remotePath)")
            UserDefaults.standard.set(workingDirRaw, forKey: wd)
            UserDefaults.standard.set(items[i].name, forKey: fn)
            UserDefaults.standard.set(remotePath.absoluteString, forKey: rp)

        }
        
        worksCount += items.count
        UserDefaults.standard.set(worksCount, forKey: "UploadManager_WorksCount")
        
    }
    
//    func uploadToCloud(){
//        guard !items.isEmpty else {return}
//        
//        
//        for i in 0...items.count-1{
//            print("uploading image \(i)")
//            var remotePath =  workingDirectoryServer.appending(path: items[i].name)
//            
//            guard let localUrl = items[i].url else {continue}
//            
//            //change localurl to remote for items
//            //items[i].localURL = URL(string: remotePath) ?? items[i].remoteURL
//            let storageRef = storage.reference(withPath: remotePath.path())
//            
//            let uploadTask = storageRef.putFile(from: localUrl)
//            
//           
//            // Listen for state changes, errors, and completion of the upload.
//            uploadTask.observe(.resume) { snapshot in
//                // Upload resumed, also fires when the upload starts
//            }
//            
//            uploadTask.observe(.pause) { snapshot in
//                // Upload paused
//            }
//            
//            uploadTask.observe(.progress) { snapshot in
//                // Upload reported progress
//                
//                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
//                / Double(snapshot.progress!.totalUnitCount)
//                print("upload progress: \(percentComplete)")
//            }
//            
//            uploadTask.observe(.success) { snapshot in
//                // Upload completed successfully
//                print("upload Successfully")
//                               
//            }
//            
//            
//            uploadTask.observe(.failure) { snapshot in
//                if let error = snapshot.error as? NSError {
//                    switch (StorageErrorCode(rawValue: error.code)!) {
//                    case .objectNotFound:
//                        // File doesn't exist
//                        print("Upload Error: objectNotFound")
//                        break
//                    case .unauthorized:
//                        // User doesn't have permission to access file
//                        print("Upload Error: unauthorized")
//                        break
//                    case .cancelled:
//                        // User canceled the upload
//                        print("Upload Error: cancelled")
//                        break
//                        
//                        /* ... */
//                        
//                    case .unknown:
//                        // Unknown error occurred, inspect the server response
//                        print("Upload Error: unknown")
//                        break
//                    default:
//                        // A separate error occurred. This is a good place to retry the upload.
//                        print("Upload Error: default")
//                        break
//                    }
//                }
//            }}
//        
//        
//    }

    

    
    private func downloadItem(_ item: DataItem){
        let localPath = workingDirectory.appending(path: item.name)
        
        print("Downloading file \(item.name) from \(workingDirectoryServer.appending(path: item.name).path())")
        //create subDir if not exist
        do {
            try FileManager.default.createDirectory(atPath: localPath.deletingLastPathComponent().path(), withIntermediateDirectories: true, attributes: nil)
        } catch {print(error)}
        
        //create remote reference
        let testRef = storage.reference(withPath: workingDirectoryServer.appending(path: item.name).path())
        
        //start download
        downloadTasks.append(testRef.write(toFile: localPath))
        
        downloadTasks[downloadTasks.count-1].observe(.success) { snapshot in
          print("Download completed successfully \(snapshot.reference.name.removingPercentEncoding!)")
       
            if(self.getItemIndex(snapshot.reference.name.removingPercentEncoding!) != nil){
                print("calling willChange")
                let itemName = snapshot.reference.name.removingPercentEncoding!
                
                self.willUpdateData()
                self.items[self.getItemIndex(itemName)!].downloadError = false
                self.items[self.getItemIndex(itemName)!].downloaded = true
            }
        }
        
        //Download Observers
        downloadTasks[downloadTasks.count-1].observe(.pause) { snapshot in
            print("Download pause")
          }
        downloadTasks[downloadTasks.count-1].observe(.unknown) { snapshot in
            print("Download unknown")
          }
        downloadTasks[downloadTasks.count-1].observe(.failure) { snapshot in
            
            print("Download error \(self.items.firstIndex(where: {$0.name == snapshot.reference.name.removingPercentEncoding})!)")
            
            if(self.getItemIndex(snapshot.reference.name) != nil){
                self.willUpdateData()
                self.items[
                    self.getItemIndex(snapshot.reference.name)!
                ].downloadError = true
                
            }
            
        }
    }
    
    func addItem(_ item: DataItem, downloadAllowed : Bool = true) {
        print("addItem \(item.name) in \(workingDirectory.absoluteString)")
        if item.name.isEmpty {print("Empty name"); return}
        if getItem(item.name) != nil {print("Aready Exist"); return}
        
        let localPath = workingDirectory.appending(path: item.name)
        var tempItem = DataItem(name: item.name, url: localPath)
       
        
        
        if(FileManager.default.fileExists(atPath: localPath.path)){
            print("File already downloaded")
            tempItem.downloaded = true
            self.willUpdateData()
            items.append(tempItem)
        }else{
            print("Downloading File")
            self.willUpdateData()
            items.append(tempItem)
            if downloadAllowed {downloadItem(item)}
        }
    }
    
    
    func addItems(_ items: [DataItem], downloadAllowed : Bool = true){
        guard !items.isEmpty else { return }
        for i in 0...items.count-1{
            addItem(items[i], downloadAllowed: downloadAllowed)
        }
    }
    
    func getItem(_ name : String) -> DataItem? {
        guard let item = items.first(where: {$0.name == name}) else {return nil}
        return item//items.first(where: {$0.name == name})
    }
    
    func getItemBinding(_ name : String) -> Binding<DataItem>? {
        guard let item = items.first(where: {$0.name == name}) else {return nil}
        for i in 0...items.count-1{
            if items[i].name == name {
                return Binding(get: {self.items[i]}, set: {self.items[i] = $0})
            }
        }
        return nil
    }
    
    func getItemIndex(_ name : String) -> Int? {
        return items.firstIndex(where: {$0.name == name})
    }
    
    /// Removes an item from the data collection.
    func removeItem(_ item: DataItem,localyOnly : Bool = false) {
        if let index = items.firstIndex(of: item) {
        self.willUpdateData()
        //remove from items
        items.remove(at: index)
        //remove from local directory
        FileManager.default.removeItemFromDocumentDirectory(filePath: workingDirectory.appending(path: item.name))
        
        if(!localyOnly){
                //remove from remote directory
                let remotePath = workingDirectoryServer.appending(path: item.name)
                let storageRef = storage.reference(withPath: remotePath.path(percentEncoded: true))
                print("Deleting remote file \(remotePath.path(percentEncoded: true)))")
                storageRef.delete { error in
                    if let error = error {
                        print("Error deleting file \(item.name)")
                    } else {
                        print("File \(item.name) delete from remote storage")
                    }
                }
            }
        }
    }
    
    func removeAllExceptLast(localyOnly: Bool = false ){
        if(items.isEmpty){return}
        if(items.count == 1){return}
        for i in (0...items.count-2).reversed(){
                removeItem(items[i],localyOnly: localyOnly)
        }
    }
    
    func removeAllExceptFirst(localyOnly: Bool = false ){
        if(items.count <= 1){return}
        for i in (1...items.count-1).reversed(){
                removeItem(items[i],localyOnly: localyOnly)
        }
    }
    
    func saveItem(item: PhotoItem, imageData: Data){
        
    }
    
}






struct DataItem: Identifiable {
    let id = UUID()
    var downloaded = false
    var downloadError = false
    var name: String
    var url: URL?

}

extension DataItem: Equatable {
    static func ==(lhs: DataItem, rhs: DataItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}



