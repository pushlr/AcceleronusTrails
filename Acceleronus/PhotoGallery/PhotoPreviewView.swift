//
//  PhotoPreviewView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 24.10.2023.
//

import SwiftUI

struct PhotoPreviewView2: View {
        @Binding var items: [PhotoItem]
        @Binding var itemIndex : Int
        @Binding var isPresented: Bool
    
        @State private var scale: CGFloat = 1
        @State private var lastScale: CGFloat = 1

        @State private var offset: CGPoint = .zero
        @State private var lastTranslation: CGSize = .zero

//        public init(item: PhotoItem) {
//            self.item = item
//        }

        public var body: some View {
            GeometryReader { proxy in
                ZStack {
                    //current image
                    AsyncImage(url: items[itemIndex].url) { image in
                        image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(x: offset.x, y: offset.y)
                        .gesture(makeDragGesture(size: proxy.size))
                        .gesture(makeMagnificationGesture(size: proxy.size))
                    } placeholder: {
                        ProgressView()
                    }
                    //next image
                    if(itemIndex<items.count-1){
                        AsyncImage(url: items[itemIndex+1].url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(x: offset.x+UIScreen.main.bounds.width,
                                        y: offset.y)
                                .gesture(makeDragGesture(size: proxy.size))
                                .gesture(makeMagnificationGesture(size: proxy.size))
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                
                
                
                Button{
                  isPresented = false
                }label: {
                    Text("< Back")
                        .padding()
                }
                
                
                Button{
                    print("Next Image \(self.itemIndex)")
                    if(itemIndex<items.count-1){
                        self.itemIndex = self.itemIndex + 1
                    }
                    print("Next Image \(self.itemIndex)")
                }label: {
                    Text("Next Image")
                }
            }
        }

        private func makeMagnificationGesture(size: CGSize) -> some Gesture {
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    lastScale = value

                    // To minimize jittering
                    if abs(1 - delta) > 0.01 {
                        scale *= delta
                    }
                }
                .onEnded { _ in
                    lastScale = 1
                    if scale < 1 {
                        withAnimation {
                            scale = 1
                            
                        }
                    }
                    print("scale \(scale)")
                    adjustMaxOffset(size: size)
                }
        }

        private func makeDragGesture(size: CGSize) -> some Gesture {
            DragGesture()
                .onChanged { value in
                    let diff = CGPoint(
                        x: value.translation.width - lastTranslation.width,
                        y: value.translation.height - lastTranslation.height
                    )
                    print(diff)
                    offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
                    print("offset \(offset)")
                    lastTranslation = value.translation
                }
                .onEnded { value in
                    adjustMaxOffset(size: size)
                   
                    if value.translation.width < 0 {
                       print("left")
                        if(scale==1){
                            if(itemIndex<items.count-1){
                                self.itemIndex = self.itemIndex + 1
                            }
                        }
                    }

                    if value.translation.width > 0 {
                        // right
                        print("right")
                        if(scale==1){
                            if(itemIndex>0){
                                self.itemIndex = self.itemIndex - 1
                            }
                        }
                    }
                    if value.translation.height < 0 {
                        // up
                    }

                    if value.translation.height > 0 {
                        // down
                    }
                                        
                }
        }

        private func adjustMaxOffset(size: CGSize) {
            print("adjusting offset")
            let maxOffsetX = (size.width * (scale - 1)) / 2
            let maxOffsetY = (size.height * (scale - 1)) / 2

            var newOffsetX = offset.x
            var newOffsetY = offset.y

            if abs(newOffsetX) > maxOffsetX {
                newOffsetX = maxOffsetX * (abs(newOffsetX) / newOffsetX)
            }
            if abs(newOffsetY) > maxOffsetY {
                newOffsetY = maxOffsetY * (abs(newOffsetY) / newOffsetY)
            }

            let newOffset = CGPoint(x: newOffsetX, y: newOffsetY)
            if newOffset != offset {
                withAnimation {
                    offset = newOffset
                    print(newOffset)
                }
            }
            self.lastTranslation = .zero
        }
}


struct TextFieldView_Previews: PreviewProvider {
  
  
    static var previews: some View {
        
        @State var item: Int = 0
        PhotoPreviewView2(
            items: .constant(
                [PhotoItem(name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/1.sm.png")!),
                              
                 PhotoItem(name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/2.sm.png")!),
                 PhotoItem(name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/3.sm.png")!)
                
                ]),
            itemIndex: $item,
            isPresented: .constant(true)
            
        )
    }
    
}
//#Preview {
//
//   // TextFieldView_Previews()
//}
