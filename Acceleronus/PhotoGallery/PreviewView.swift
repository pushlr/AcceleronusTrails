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
                         subject: Text("Trail Photo"),
                         message: Text("Check it out!"),
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
            

            
//            PhotoViewer(index: $itemIndex,
//                        urls: items.map { $0.url! },
//                        isPresented: $isPresented)
            
            SwipeZoomGallery(currentIndex: $itemIndex, isPresented: $isPresented, urls:
                items.compactMap { $0.url}
            )
            
//            GeometryReader { proxy in
//                TabView(selection: $itemIndex) {
//                    ForEach(0..<items.count, id: \.self){index in
//                        
//                        VStack(){
//                            if(items[index].downloadError){
//                                VStack{
//                                    Image(systemName: "exclamationmark.triangle.fill")
//                                        .foregroundStyle(.yellow)
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                    Text("Cannot download image from server!")
//                                        .font(.caption)
//                                }
//                               
//                                
//                            }else{
//                                AsyncImage(url: items[index].url) { image in
//                                    image
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .scaleEffect(index == itemIndex ? scale : 1)
//
//                                    
//                                } placeholder: {
//                                    ProgressView()
//                                }
//                            }
//                            
//                        }
//                        .tag(index)
//                        .frame(width: proxy.size.width, height: proxy.size.height)
//                                               .contentShape(Rectangle())
//                        .offset(x: (CGFloat(index - itemIndex) * UIScreen.main.bounds.width*scale + offset.x),
//                                y: (scale == 1) ? 0 : offset.y)//image position Y only when is scalled
//
//                        
//                        
//                        
//                    }
//                        
//                    
//                    
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//             //   .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
//                .highPriorityGesture(makeDragGesture(size: proxy.size))
//                .gesture(makeMagnificationGesture(size: proxy.size))
//                .gesture(tapGesture(size: proxy.size))
//                
//                
//            } //geomery reader
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
//                print("Change image offset : \(offset)")
                
                // prev/next photo gesture
                if(abs(value.translation.width) > 50 ){ //(UIScreen.main.bounds.width / 5)
                    if(value.translation.width>0)
                    {
                        //print("prev photo")
                        isPrev = true
                    }else
                    {
                        //print("next photo")
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
                print("Drag end")
                adjustMaxOffset(size: size)
               

                if(scale==1){
                    withAnimation{
                        if(isPrev && itemIndex>0) {itemIndex = itemIndex-1;print("prev photo")}
                        if(isNext && itemIndex<items.count-1) {itemIndex = itemIndex+1;print("next photo")}
                        offset = .zero
                        
                    }
                } else {print("scalled \(scale)")}
               
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
        print("Adjusting max offset")
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
        print("Old offset: \(offset)")
        if newOffset != offset {
            withAnimation {
                offset = newOffset
                print("New offset: \(newOffset)")
            }
        }
        self.lastTranslation = .zero
    }
    
    
}





struct PhotoViewer: View {
    @Binding var index: Int
    let urls: [URL]
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $index) {
                ForEach(urls.indices, id: \.self) { i in
                    ZoomableImage(url: urls[i], scale: $scale, offset: $offset)
                        .tag(i)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .contentShape(Rectangle())
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .gesture(closeGesture)
        }
    }
    
    /// Swipe down to close (only when not zoomed)
    var closeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if scale == 1 && value.translation.height > 100 {
                    isPresented = false
                }
            }
    }
}


struct ZoomableImage: View {
    let url: URL
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(zoomGesture)
                .gesture(dragGesture)
                .gesture(doubleTapGesture)
        } placeholder: {
            ProgressView()
        }
    }
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
                scale = max(scale, 1)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                        lastScale = 1
                    } else {
                        scale = 3
                        lastScale = 3
                    }
                }
            }
    }
}


#Preview {
///    DemoView()
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


struct DemoView: View {
    @State var idx = 0
    @State var shown = true
    var body: some View {
        SwipeZoomGallery(currentIndex: $idx, isPresented: $shown, urls: [
            URL(string:"https://picsum.photos/id/1011/900/600")!,
            URL(string:"https://picsum.photos/id/1015/900/600")!,
            URL(string:"https://picsum.photos/id/1016/900/600")!
        ])
    }
}



/// Drop-in gallery. Use SwipeZoomGallery(urls:..., currentIndex:..., isPresented:...)
struct SwipeZoomGallery: View {
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool
    let urls: [URL]

    // transient drag for page swipe (only used when current page is not zoomed)
    @State private var dragTranslation: CGFloat = 0

    // per-page zoom & pan state
    @State private var pageScales: [CGFloat]
    @State private var pageOffsets: [CGSize]

    // gesture helpers
    init(currentIndex: Binding<Int>, isPresented: Binding<Bool>, urls: [URL]) {
        self._currentIndex = currentIndex
        self._isPresented = isPresented
        self.urls = urls

        // initial per-page state
        let scales = Array(repeating: CGFloat(1.0), count: urls.count)
        let offsets = Array(repeating: CGSize.zero, count: urls.count)
        _pageScales = State(initialValue: scales)
        _pageOffsets = State(initialValue: offsets)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .top) {
                // HStack of pages
                HStack(spacing: 0) {
                    ForEach(urls.indices, id: \.self) { idx in
                        ZoomablePage(
                            url: urls[idx],
                            scale: $pageScales[idx],
                            offset: $pageOffsets[idx],
                            onHorizontalDrag: { translation, ended in
                                handlePageDrag(translation: translation,
                                               ended: ended,
                                               width: w)
                                })
                        .frame(width: w, height: h)
                       
                     
                    }
                }
                // total gallery offset = center on currentIndex + transient drag
                .offset(x: -CGFloat(currentIndex) * w + dragTranslation)
                .animation(.interactiveSpring(), value: currentIndex)
                .gesture(pageDragGesture(width: w))
                .simultaneousGesture(closeGesture())
                
                .ignoresSafeArea()

//                // Page indicator
//                HStack(spacing: 8) {
//                    Text("\(currentIndex + 1) / \(urls.count)")
//                        .font(.subheadline)
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(Capsule())
//                }
//                .padding(.top, 44)
            }
            // optional: close on swipe down when not zoomed
            .gesture(closeOnSwipeDown())
        }
    }

    private func closeGesture() -> some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                if !isPageZoomed(index: currentIndex) &&
                    value.translation.height > 150 &&
                    abs(value.translation.height) > abs(value.translation.width) {
                    isPresented = false
                }
            }
    }

    
    private func handlePageDrag(translation: CGFloat, ended: Bool, width: CGFloat) {
        // If current page is zoomed → do NOT swipe pages
      
        if isPageZoomed(index: currentIndex) { return }

        if !ended {
            // live drag
            print("handlePageDrag OnChange")
            dragTranslation = translation
            return
        }
        print("handlePageDrag End")
        // drag ended → check thresholds
        let threshold = width * 0.25

        if translation < -threshold && currentIndex < urls.count - 1 {
            currentIndex += 1
        } else if translation > threshold && currentIndex > 0 {
            currentIndex -= 1
        }

        withAnimation(.spring()) {
            dragTranslation = 0
        }
    }


    
    // MARK: - Page drag (handles paging). Disabled while current page is zoomed (>1).
    private func pageDragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                print("pageDragGesture onChange")
                // if current page zoomed, do not change dragTranslation (we want panning instead)
                if isPageZoomed(index: currentIndex) { return }
                dragTranslation = value.translation.width
            }
            .onEnded { value in
                print("pageDragGesture End")
                guard !isPageZoomed(index: currentIndex) else {
                    dragTranslation = 0
                    return
                }

                let velocity = abs(value.predictedEndTranslation.width - value.translation.width)
                // convert velocity into damping (fast drag = lower damping = softer spring)
                let damping = max(0.5, min(1.0, 1.0 - (velocity / 2000)))
                let response = 0.35 + (velocity / 5000) // small drag = tight; fast drag = slower
                
                
                let threshold = width * 0.25
                let translation = value.translation.width

                var newIndex = currentIndex
                
                if translation < -threshold && currentIndex < urls.count - 1 {
                    newIndex += 1
                } else if translation > threshold && currentIndex > 0 {
                    newIndex -= 1
                }

                // snap back
                // 1. Animate slide to next page position
                let targetOffset = CGFloat(newIndex - currentIndex) * -width

                
                withAnimation(.spring(response: response,
                                      dampingFraction: damping,
                                      blendDuration: 0.2)) {
                    dragTranslation = targetOffset
                }
             
                // 2. After animation finishes, update index and reset translation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        currentIndex = newIndex
                        dragTranslation = 0
                    }
                
            }
    }

    private func isPageZoomed(index: Int) -> Bool {
        guard pageScales.indices.contains(index) else { return false }
        return pageScales[index] > 1.001
    }

    // optional: close by swiping down if not zoomed
    private func closeOnSwipeDown() -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                // only close if vertical swipe and current page not zoomed
                if abs(value.translation.height) > 150 && abs(value.translation.height) > abs(value.translation.width) {
                    if !isPageZoomed(index: currentIndex) {
                        isPresented = false
                    }
                }
            }
    }
}


/// Single page view with pinch/double-tap/pan. Uses .highPriorityGesture for pan so it wins over container gestures when zoomed.
struct ZoomablePage: View {
    let url: URL
    @Binding var scale: CGFloat
    @Binding var offset: CGSize

    @State private var gestureScale: CGFloat = 1.0
    @State private var gestureOffset: CGSize = .zero
    @State private var pinchCenter: CGPoint? = nil

    @GestureState private var magnifyBy = 1.0
    
    
    // callback to parent gallery
    var onHorizontalDrag: (_ translation: CGFloat, _ ended: Bool) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.ignoresSafeArea()

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                            .scaleEffect(scale * gestureScale)
                            .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                            .animation(.interactiveSpring(), value: scale)
                            .animation(.interactiveSpring(), value: offset)
                            .animation(.interactiveSpring(), value: gestureOffset)

                            // zoom gestures
                            .simultaneousGesture(magnification())
                            .simultaneousGesture(pan(availableSize: geo.size))
                            .simultaneousGesture(doubleTapGesture())
                            .animation(.interactiveSpring(), value: scale)
                                   .animation(.interactiveSpring(), value: offset)

                    case .empty:
                        ProgressView()
                    case .failure:
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Cannot download image")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
    

    // MARK: Gestures

    private func magnification() -> some Gesture {
        MagnifyGesture()
 
             .updating($magnifyBy) { value, gestureState, transaction in
                 print("updating")
                 gestureState = value.magnification
                 let unitPoint = value.startAnchor
                 pinchCenter = CGPoint(
                     x: unitPoint.x * UIScreen.main.bounds.size.width,
                     y: unitPoint.y * UIScreen.main.bounds.size.height
                 )
                 
                 //update scale
                 gestureScale = value.magnification
            

//                 //image offset
//                 let w = (pinchCenter!.x - (pinchCenter!.x - offset.width) * gestureScale)
//                 let h = (pinchCenter!.y - (pinchCenter!.y - offset.height) * gestureScale)
//                 gestureOffset = CGSize(width: w, height: h)

             }
        
             .onEnded(){value in
                 print("end")
                 
                    //permanent scale
                    scale = (scale * value.magnification).clamped(to: 1...15)

                    // permanent image offset
                    offset = CGSize(
                        width: offset.width + gestureOffset.width,
                        height: offset.height + gestureOffset.height
                    )

                    // reset temporary values
                    gestureScale = 1
                    gestureOffset = .zero
                    pinchCenter = nil

                    clampOffset(availableSize:  UIScreen.main.bounds.size)
                
             }
   
        
//        MagnificationGesture()
//            .onChanged { value in
//                gestureScale = value
//            }
//            .onEnded { value in
//                let oldScale = scale
//                let newScale = (scale * value).clamped(to: 1...10)
//                let size = UIScreen.main.bounds.size
//                // compute zoom focus point (current finger location)
//                if let location = lastGestureLocation {
//                    let centerX = size.width / 2
//                    let centerY = size.height / 2
//
//                    // vector from center → tap point
//                    let dx = location.x - centerX
//                    let dy = location.y - centerY
//
//                    // adjust offset
//                    let deltaScale = newScale / oldScale
//                    offset = CGSize(
//                        width: offset.width + dx * (deltaScale - 1),
//                        height: offset.height + dy * (deltaScale - 1)
//                    )
//                }
//
//                scale = newScale
//                gestureScale = 1
//
//                clampOffset(availableSize: size)
//            }
    }


    private func pan(availableSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // only pan when zoomed
                let currentScale = scale * gestureScale
                if currentScale <= 1.001 {
                    //onHorizontalDrag(value.translation.width, false)
                    return
                }
                gestureOffset = value.translation
            }
            .onEnded { value in
                let currentScale = scale * gestureScale
                if currentScale <= 1.001 {
                    gestureOffset = .zero
                    // maybe next/prev photo?
                    //onHorizontalDrag(value.translation.width, true)
                    return
                }

                // commit gesture offset into persistent offset, then clamp
                offset = CGSize(width: offset.width + gestureOffset.width, height: offset.height + gestureOffset.height)
                gestureOffset = .zero
                clampOffset(availableSize: availableSize)
                
                
            }
    }

    
    private func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut) {
                if scale > 1.01 {
                    // reset
                    scale = 1
                    offset = .zero
                } else {
                    scale = 3
                }
            }
        }
    }

    // MARK: - Helpers
    private func clampOffset(availableSize: CGSize) {
        // Compute max allowed offsets so image stays visible.
        // This is a simple heuristic based on scaled image size vs screen size.

        let screenW = availableSize.width
        let screenH = availableSize.height

        let s = scale
        // assume image fully fits inside screen when scale==1, so extra size is (s-1)*screen
        let maxX = max(0, (s - 1) * screenW / 2)
        let maxY = max(0, (s - 1) * screenH / 2)

        var x = offset.width
        var y = offset.height

        x = x.clamped(to: -maxX...maxX)
        y = y.clamped(to: -maxY...maxY)

        offset = CGSize(width: x, height: y)
    }
}


/// simple helpers
fileprivate extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
fileprivate extension CGFloat {
    func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        CGFloat.minimum(CGFloat.maximum(self, limits.lowerBound), limits.upperBound)
    }
}

