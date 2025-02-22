/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GridItemView: View {
    @EnvironmentObject var dataStorage: DataStorage
    let size: Double
    let storageid: String?
    let itemIndex : Int

    
    var body: some View {
        if let imageStorage : DataStorageItem = dataStorage.getStorage(storageid ?? ""){
            ZStack(alignment: .topTrailing) {
                
                if(imageStorage.items.count > 0  && itemIndex < imageStorage.items.count){ //when delete error
                
                if(imageStorage.items[itemIndex].downloaded == false ){
                    if(imageStorage.items[itemIndex].downloadError){
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .frame(maxWidth: size, alignment: .center)
                    }else{
                        
                        ProgressView()
                            .frame(width: size, height: size, alignment: .center)
                    }
                }else{
                    
                    AsyncImage(url: imageStorage.items[itemIndex].url,
                               //  transaction: Transaction(animation: .easeIn(duration: 1.0)),
                               content: { state in
                        switch state {
                        case .empty:
                            ProgressView()
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            
                        @unknown default:
                            EmptyView()
                        }
                        
                    }).frame(width: size, height: size)
                    
                  
                    
                }
                
                    }//if valid index
                
                
            }
        }
    }
    
}

//struct GridItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
//            GridItemView(size: 50, item: PhotoItem(name:"myshy1", url: url))
//        }
//    }
//}
