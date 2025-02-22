/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GridView: View {
    @EnvironmentObject var dataStorage: DataStorage
    let storageID : String
    
    var EditingMode : Bool = false
    var labelFont : Font = .headline
    
    private static let initialColumns = 3//UserDefaults.standard.integer(forKey: "galleryColumn")
    @State private var isAddingPhoto = false
    @State private var isTakingPhoto = false
    @State private var isEditing = false
    @State private var isPreview = false
  //  @State private var isPreviewItem : PhotoItem = PhotoItem(name:"", url: URL(string: "www.google.com")!)
    @State private var isPreviewItem : Int = 0
    @State private var imageWasAdded = false 
    
    @State private var gridColumns = Array(repeating: GridItem(.flexible(),spacing: 5), count: initialColumns)
    @State private var numColumns = (initialColumns>0 ? initialColumns : 3)
    
    private var columnsTitle: String {
    //    gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
        "\(gridColumns.count) Columns"
    }
    
    var body: some View {
        if(dataStorage.getStorage(storageID) != nil){
            VStack {
                //            if isEditing {
                //                ColumnStepper(title: columnsTitle, range: 1...8, columns: $gridColumns)
                //                .padding()
                //            }
                
                //control buttons
                HStack{
                    Text("Gallery (\(dataStorage.getStorage(storageID)!.items.count))").frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .font(labelFont)
                    
                    if(EditingMode){
                        Button(isEditing ? "Done" : "Edit") {withAnimation { isEditing.toggle() }} .padding(.trailing,10)
                        
                        Button {isAddingPhoto = true}
                    label: {Image(systemName: "plus")}
                            .disabled(isEditing)
                            .padding(.trailing,10)
                        
                        Button {isTakingPhoto = true}
                    label: {Image(systemName: "camera")}
                            .disabled(isEditing || !UIImagePickerController.isSourceTypeAvailable(.camera))
                            
                            .padding(.trailing,10)
                        
                    }
                }
                
                ScrollView {
                    LazyVGrid(columns: gridColumns,spacing: 3) {
                        ForEach(Array(dataStorage.getStorage(storageID)!.items.enumerated()),id: \.offset) { index,item in
                      //  for index in 0...dataStorage.getStorage(storageID)!.items.count-1 { let item = dataStorage.getStorage(storageID)!.items[index]
                            
                            GeometryReader { geo in
                                Button{
                                    isPreviewItem = dataStorage.getStorage(storageID)!.items.firstIndex(of: item)!
                                    isPreview = true
                                    
                                }label:
                                {
                                    GridItemView(size: geo.size.width, storageid: storageID, itemIndex: index)
                                }
                                
                            }
                            .cornerRadius(5.0)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(alignment: .topTrailing) {
                                if isEditing {
                                    Button {
                                        withAnimation {
                                            
                                            dataStorage.getStorage(storageID)!.removeItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.square.fill")
                                            .font(Font.title)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .red)
                                    }
                                    .offset(x: 7, y: -2)
                                }
                            }
                        }
                    }
                    //  .padding(.top,10)
                    
                }.padding(.top,10)
            }.onAppear{
                print("Grid appear \(dataStorage.getStorage(storageID)!.items.count)")
            }
            
            //     .navigationBarTitle("WayPoint Images")
            //    .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isAddingPhoto) {
                PhotoPicker(storageID: storageID, imageSelected: $imageWasAdded)
            }
            .fullScreenCover(isPresented: $isTakingPhoto) {
               
                    PhotoShoter(storageID: storageID)
                        .edgesIgnoringSafeArea(.all)
                
                
                
            }
            
            //        .toolbar {
            //            ToolbarItem(placement: .navigationBarLeading)
            //            {
            //                Text("WayPoint Images").font(.headline)
            //                .padding(-15)
            //            }
            //            ToolbarItem(placement: .navigationBarTrailing) {
            //                Button(isEditing ? "Done" : "Edit") {
            //                    withAnimation { isEditing.toggle() }
            //                }
            //            }
            //            ToolbarItem(placement: .navigationBarTrailing) {
            //                Button {
            //                    isAddingPhoto = true
            //                } label: {
            //                    Image(systemName: "plus")
            //                }
            //                .disabled(isEditing)
            //            }
            //
            //            ToolbarItem(placement: .navigationBarTrailing) {
            //                Button {
            //                    isTakingPhoto = true
            //                } label: {
            //                    Image(systemName: "camera")
            //                }
            //                .disabled(isEditing)
            //            }
            //
            //        }
            
            .fullScreenCover(isPresented: $isPreview, content:
                                {
                PreviewView(items: dataStorage.getStorageBinding(storageID)!.items, itemIndex: $isPreviewItem,isPresented: $isPreview)}
            )
            
            
            
        }}
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(storageID: "s", EditingMode: true)
            .previewDevice("iPad (8th generation)")
            .environmentObject(PhotoStorageModel(workDir: "/"))
            //.environmentObject(DataStorage().createStorageFor(Trail(id: UUID())))
    }
}
 
