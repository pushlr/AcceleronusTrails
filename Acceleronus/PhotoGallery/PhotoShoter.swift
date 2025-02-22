//
//  PhotoShoter.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 13.12.2023.
//

import SwiftUI

struct PhotoShoter: UIViewControllerRepresentable {
        
     //   @Binding var selectedImage: UIImage?
        @Environment(\.presentationMode) var isPresented
    
        @EnvironmentObject var dataStorage: DataStorage
        var storageID : String
        //@Binding var imageSelected : Bool
    
        func makeUIViewController(context: Context) -> UIImagePickerController {
 
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
           // imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            imagePicker.delegate = context.coordinator
            
            return imagePicker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
            
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(picker: self)
        }
    }

    // Coordinator will help to preview the selected image in the View.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: PhotoShoter
        
        init(picker: PhotoShoter) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          
            print("Photo: \(info)")
            guard let image = info[.originalImage] as? UIImage else { return }
//            self.picker.selectedImage = selectedImage
            let imageData = image.jpegData(compressionQuality: 0.3)
            
            let workingDirectory = self.picker.dataStorage.getStorage(self.picker.storageID)!.workingDirectory
            
            var imagePath : URL
            var i = 0
            repeat{
                imagePath = workingDirectory
                    .appending(path: "AccTrail" + String(format: "%04d", i))
                    //.deletingPathExtension()
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
                Task { @MainActor [dataModel = self.picker.dataStorage.getStorage(self.picker.storageID)!] in
                        withAnimation {
                            let item = DataItem(name: imagePath.lastPathComponent, url: imagePath)
                            dataModel.addItem(item)
                          
                        }
                    }
            }else{
                print("Fail to create photo file")
                
            }
            
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }

    

//#Preview {
//    PhotoShoter()
//}
