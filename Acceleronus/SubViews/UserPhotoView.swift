//
//  UserPhotoView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 29.11.2023.
//

import SwiftUI

struct UserPhotoView: View {
    //@EnvironmentObject var photoStorage: PhotoStorageModel
    @EnvironmentObject var dataStorage : DataStorage
    @State var storageID : String
   // @EnvironmentObject var userData : UserData
    
    let imageName : String
    
    var body: some View {
        if(dataStorage.getStorage(storageID) != nil){
            Group{
                if(dataStorage.getStorage(storageID)!.getItem(imageName) != nil){
                    //  if(photoStorage.items.count > 0){
                    if(dataStorage.getStorage(storageID)!.getItem(imageName)!.downloaded == false ){
                        if(dataStorage.getStorage(storageID)!.getItem(imageName)!.downloadError){
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            // .frame(maxWidth: size, alignment: .center)
                        }else{
                            
                            ProgressView()
                            //  .frame(width: size, height: size, alignment: .center)
                        }
                    }else{
                        AsyncImage(url: //photoStorage.items[0].url,
                                   dataStorage.getStorage(storageID)!.getItem(imageName)!.url,
                                   content: { state in
                            switch state {
                            case .empty:
                                ProgressView()
                                
                            case .success(let image):
                                image.resizable()
                                
                                
                            case .failure:
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.title)
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                        )
                    }
                }else{
                    Image(uiImage: UIImage(named: "Image 1")!)
                        .resizable()
                }
            }
            
            
        }else{
           Text("error")
        }
    }
}

#Preview {
    UserPhotoView(storageID: "", imageName: "")
}
