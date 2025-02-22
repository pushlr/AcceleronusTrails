//
//  PreviewView.swift
//  Acceleronus
//
//  Created by Françoise d'Aubigné on 28.10.2023.
//

import SwiftUI

struct PreviewView: View {
    @Binding var items: [DataItem]
    @Binding var itemIndex : Int
    @Binding var isPresented: Bool
    
    
    //item modifications
    @State  private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State  private var offset: CGPoint = .zero
 
    @State  private var lastTranslation: CGSize = .zero
    @State  private var isPrev = false
    @State  private var isNext = false
   
    
    
    public var body: some View {
        
        VStack(spacing: 0){
            HStack(alignment: .center,spacing: 0){
                Button{
                    isPresented = false
                }label: {
                    HStack(spacing: 0){
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }.padding(.leading,10)
                }.frame(width: UIScreen.main.bounds.width / 3.0,alignment: .leading)
               
                
                   
                
                Text("\(itemIndex+1) / \(items.count)")
                    .frame(width: UIScreen.main.bounds.width / 3.0,alignment: .center)
                  
                    .font(.subheadline)
                    
                
                            
               ShareLink(item: items[itemIndex].downloaded ? Image(uiImage: UIImage(data: try! Data(contentsOf: items[itemIndex].url!))!) : Image(systemName: ""),
                         preview: items[itemIndex].downloaded ? SharePreview("Trail Photo",image: Image(uiImage: UIImage(data: try! Data(contentsOf: items[itemIndex].url!))!)) : SharePreview("s",image: Image(systemName: "")),
                              label: {Image(systemName: "square.and.arrow.up")}
                              
                    )
                    .padding(.trailing,10)
                    .frame(width: UIScreen.main.bounds.width / 3.0,alignment: .trailing)
                    .disabled(!items[itemIndex].downloaded)
               
                    
                   
            }
            .padding(.bottom,15)
            .padding(.top,15)
            
            Divider()
            GeometryReader { proxy in
                ZStack {
                    ForEach(0..<items.count, id: \.self){index in
                        
                        ZStack(){
                            if(items[index].downloadError){
                                VStack{
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    Text("Cannot download image from server!")
                                        .font(.caption)
                                }
                               
                                
                            }else{
                                AsyncImage(url: items[index].url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(index == itemIndex ? scale : 1)
                                        
                                    
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .offset(x: (CGFloat(index - itemIndex) * UIScreen.main.bounds.width*scale + offset.x),
                                y: (scale == 1) ? 0 : offset.y)//image position Y only when is scalled
                        .gesture(makeDragGesture(size: proxy.size))
                        .gesture(makeMagnificationGesture(size: proxy.size))
                        .gesture(tapGesture(size: proxy.size))
                        
                        
                        
                    }
                        
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                
            } //geomery reader
        }
    }
    
    
    
    private func tapGesture(size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            print("double tap")
            withAnimation{
                if(scale == 1){
                    scale = 3
                    
                }else{
                scale = 1
                adjustMaxOffset(size: size)
                }
            }

        }
            
    }
    
    private func makeDragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let diff = CGPoint(
                    x: value.translation.width - lastTranslation.width,
                    y: value.translation.height - lastTranslation.height
                )
               
                //change image offset
                offset = .init(x: offset.x + diff.x, y: offset.y + diff.y)
              
                // prev/next photo gesture
                if(abs(value.translation.width) > 50 ){ //(UIScreen.main.bounds.width / 5)
                    if(value.translation.width>0)
                    {
                        print("prev photo")
                        isPrev = true
                    }else
                    {
                        print("next photo")
                        isNext = true
                    }
                }
                
                
                //close gesture
                if(abs(value.translation.height) > 100){ //(UIScreen.main.bounds.height / 5)
                    if(scale==1){isPresented = false}
                }
             
                
                
                lastTranslation = value.translation
                
            }
            .onEnded{ value in
                adjustMaxOffset(size: size)
             
                if(scale==1){
                    withAnimation{
                        if(isPrev && itemIndex>0) {itemIndex = itemIndex-1}
                        if(isNext && itemIndex<items.count-1) {itemIndex = itemIndex+1}
                        offset = .zero
                    }
                }
                
                
                lastTranslation = .zero
                isPrev = false
                isNext = false
          
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
                //adjustMaxOffset(size: size)
            }
    }
    
    
    private func adjustMaxOffset(size: CGSize) {
        
     
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
        print(offset)
        if newOffset != offset {
            withAnimation {
                offset = newOffset
                print(newOffset)
            }
        }
        self.lastTranslation = .zero
    }
    
    
}




#Preview {
    PreviewView(
        items: .constant(
            [DataItem(downloaded: true, name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/1.sm.png")!),
             
             DataItem(downloaded: true, name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/2.sm.png")!),
             DataItem(name:"default", url: URL(string: "https://www.gstatic.com/webp/gallery3/3.sm.png")!)
             
            ]),
        itemIndex: .constant(1),
        isPresented: .constant(true)
        
    )
}
