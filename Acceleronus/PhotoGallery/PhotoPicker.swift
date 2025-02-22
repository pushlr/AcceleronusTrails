/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import PhotosUI


struct PhotoPicker: UIViewControllerRepresentable {
    /// A dismiss action provided by the environment. This may be called to dismiss this view controller.
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var dataStorage: DataStorage
  //  @EnvironmentObject var userModel: UserModel
    var storageID : String
    
    @Binding var imageSelected : Bool

    
    /// Creates the picker view controller that this object represents.
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {
        
        // Configure the picker.
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        // Limit to images.
        configuration.filter = .images
        // Avoid transcoding, if possible.
        configuration.preferredAssetRepresentationMode = .current
        //configuration.selectionLimit = 10
        

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }
    
    /// Creates the coordinator that allows the picker to communicate back to this object.
    func makeCoordinator() -> PhotoCoordinator {
        PhotoCoordinator(self)
    }

    /// Updates the picker while it’s being presented.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoPicker>) {
        // No updates are necessary.
    }
}

class PhotoCoordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    let parent: PhotoPicker
    
    /// Called when one or more items have been picked, or when the picker has been canceled.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Dismisss the presented picker.
        self.parent.dismiss()
        
        guard
            let result = results.first,
            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else { return }
        parent.imageSelected = true
        // Load a file representation of the picked item.
        // This creates a temporary file which is then copied to the app’s document directory for persistent storage.
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
            if let error = error {
                print("Error loading file representation: \(error.localizedDescription)")
            } else if let url = url {
             //   guard let workingDirectory = self.parent.dataModel.workingDirectory else {return}
                let workingDirectory = self.parent.dataStorage.getStorage(self.parent.storageID)!.workingDirectory
                
                //compresss image
                print("selected image: \(url.path)")
                guard let image = UIImage(contentsOfFile: url.path) else {return}
                let imageData = image.jpegData(compressionQuality: 0.3)
                
                
                var imagePath : URL
                var i = 0
                repeat{
                    imagePath = workingDirectory
                        .appending(path: (i>0 ? String("(\(i))") : "") + url.lastPathComponent)
                        .deletingPathExtension()
                        .appendingPathExtension("jpeg")
                    i += 1
                }
                while(FileManager.default.fileExists(atPath: imagePath.path))
                   
                      
                
                print("formed path: \(imagePath.path)")
                
                //create subDir if not exist
                do {
                    try FileManager.default.createDirectory(atPath: imagePath.deletingLastPathComponent().path(), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
                                
                if (FileManager.default.createFile(atPath: imagePath.path, contents: imageData)){
                    print("File created!")
                        //Add the new item to the data model.
                    Task { @MainActor [dataModel = self.parent.dataStorage.getStorage(self.parent.storageID)!] in
                            withAnimation {
                                let item = DataItem(name: imagePath.lastPathComponent, url: imagePath)
                                dataModel.addItem(item)
                              
                            }
                        }
                }else{
                    print("Fail to create photo file")
                    
                }
//                
//                if let savedUrl = FileManager.default.copyItemToDocumentDirectory(workingDirectory: workingDirectory, from: url) {
//                    // Add the new item to the data model.
//                    Task { @MainActor [dataModel = self.parent.dataModel] in
//                        withAnimation {
//                            let item = PhotoItem(name:"ss", url: savedUrl)
//                            dataModel.addItem(item)
//                        }
//                    }
//                    }
                
                
            }
        }
    }
    
    init(_ parent: PhotoPicker) {
        self.parent = parent
    }
    
}
