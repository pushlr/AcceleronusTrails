/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation
import FirebaseStorage
import UIKit
import SwiftUI



class PhotoStorageModel: ObservableObject {
    
    @Published var items: [PhotoItem] = []
    @Published var items2: [PhotoItem] = []
    
    let storage = Storage.storage()
 
    
    var workingDirectory : URL
    var workingDirectoryServer : URL
    var downloadTasks = [StorageDownloadTask]()
    
    init(workDir: String){
        workingDirectory = FileManager.default.documentDirectory.appending(path: workDir)
        workingDirectoryServer = URL(string: workDir)!
    }
    
    func ChangeWorkDir(workDir: String){
        workingDirectory = FileManager.default.documentDirectory.appending(path: workDir)
        workingDirectoryServer = URL(string: workDir)!
    }

    func deleteWorkDir(){ //deleting all photos from localstorage and remote storage
        print("deleteWorkDir")
        //delete local diretory
        do {
            try FileManager.default.removeItem(atPath: workingDirectory.path)
        } catch {
            print(error)
        }
        
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
        
        
        for i in 0...items.count-1{
            print("uploading image \(i)")
            var remotePath =  workingDirectoryServer.appending(path: items[i].name)
            
            guard let localUrl = items[i].url else {continue}
            
            //change localurl to remote for items
            //items[i].localURL = URL(string: remotePath) ?? items[i].remoteURL
            let storageRef = storage.reference(withPath: remotePath.path())
            
            let uploadTask = storageRef.putFile(from: localUrl)
            
          
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
            
            uploadTask.observe(.success) { snapshot in
                // Upload completed successfully
                print("upload Successfully")
               
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
                        break
                    default:
                        // A separate error occurred. This is a good place to retry the upload.
                        print("Upload Error: default")
                        break
                    }
                }
            }}
        
        
    }

    
//    func checkDownloadedFiles(){
//        guard !items.isEmpty else {return}
//        
//        for i in 0...items.count-1 {
//            var localPath = workingDirectory.appending(path: items[i].name)
//            if(FileManager.default.fileExists(atPath: localPath.path)){
//               
//                if(!items[i].downloaded){
//                    print("set file \(items[i].name) as downloaded")
//                    items[i].downloaded = true
//                }
//            }
//        }
//    }
    

    func addItem(_ item: PhotoItem) {
        if item.name.isEmpty {return}
        let localPath = workingDirectory.appending(path: item.name)
        print("addItem \(item.name) in documents directory")
        var tempItem = PhotoItem(name: item.name, url: localPath)
       
        
        if(FileManager.default.fileExists(atPath: localPath.path)){
            print("File exist in DocumentsDirectory")
            tempItem.downloaded = true
            items.append(tempItem)
        }else{
            items.append(tempItem)
            //download file if not exist
            //create subDir if not exist
            do {
                try FileManager.default.createDirectory(atPath: localPath.deletingLastPathComponent().path(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
            
            
            print("Downloading file \(item.name) from \(workingDirectoryServer.appending(path: item.name).path())")
            let testRef = storage.reference(withPath: workingDirectoryServer.appending(path: item.name).path())
            downloadTasks.append(testRef.write(toFile: localPath))
            
            downloadTasks[downloadTasks.count-1].observe(.success) { snapshot in
              print("Download completed successfully \(self.items.count-1)")
           
                if(self.getItemIndex(snapshot.reference.name.removingPercentEncoding!) != nil){
                    self.items[
                        self.getItemIndex(snapshot.reference.name.removingPercentEncoding!)!
                    ].downloaded = true
                }
            }
            
            downloadTasks[downloadTasks.count-1].observe(.pause) { snapshot in
                print("Download pause")
              }
            downloadTasks[downloadTasks.count-1].observe(.unknown) { snapshot in
                print("Download unknown")
              }
            downloadTasks[downloadTasks.count-1].observe(.failure) { snapshot in
                
                print("Download error \(self.items.firstIndex(where: {$0.name == snapshot.reference.name.removingPercentEncoding})!)")
                
                if(self.getItemIndex(snapshot.reference.name) != nil){
                    self.items[
                        self.getItemIndex(snapshot.reference.name)!
                    ].downloadError = true
                }
                
            }
            
        }
        
        
       
    }
    
    
    func addItems(_ items: [PhotoItem]){
        guard !items.isEmpty else { return }
        for i in 0...items.count-1{
            addItem(items[i])
        }
    }
    
    func getItem(_ name : String) -> PhotoItem? {
        return items.first(where: {$0.name == name})
    }
    
    func getItemBinding(_ name : String) -> Binding<PhotoItem>? {
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
    func removeItem(_ item: PhotoItem) {
        if let index = items.firstIndex(of: item) {
        //remove from items
        items.remove(at: index)
        //remove from local directory
        FileManager.default.removeItemFromDocumentDirectory(filePath: workingDirectory.appending(path: item.name))
        //remove from remove directory
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
    
    func removeAllExcept(_ exceptItem: PhotoItem){
        for i in (0...items.count-1).reversed(){
            if(items[i] != exceptItem) {
                removeItem(items[i])
            }
        }
    }
    
    func saveItem(item: PhotoItem, imageData: Data){
        
    }
    
}

