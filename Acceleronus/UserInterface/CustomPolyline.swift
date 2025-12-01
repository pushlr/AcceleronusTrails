import MapKit

class CustomPolylineRenderer: MKOverlayRenderer {
    var polyline: MKPolyline
    
    override init(overlay: MKOverlay) {
        self.polyline = overlay as! MKPolyline
        super.init(overlay: overlay)
        super.accessibilityPath?.lineWidth = 6
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            guard let polyline = self.overlay as? MKPolyline else {return}
        
            let zoom = Double.minimum((8 / zoomScale), 200)
        
            //print("zoom \(zoom)")
            context.setLineWidth(8 / zoomScale)
            context.setLineJoin(.round)
            context.setLineCap(.round)
            context.setStrokeColor(UIColor.orange.cgColor)
            context.setFillColor(UIColor.red.cgColor)
        
           
//            //draw polyline
//            let path = UIBezierPath()
//            for i in stride(from: 0, to: polyline.pointCount - 1, by: 1) {
//                let startPoint = point(for: polyline.points()[i])
//                let endPoint = point(for: polyline.points()[i + 1])
//                let arrowPath = lineBetweenPoints(startPoint, endPoint)
//                path.append(arrowPath)
//            }
//            context.addPath(path.cgPath)
//            context.strokePath()
        
            
        
            //draw arrows
            for i in stride(from: 0, to: polyline.pointCount - 1, by: 5) {
                let startPoint = point(for: polyline.points()[i])
                let endPoint = point(for: polyline.points()[i + 1])
                drawArrow(startPoint: startPoint, endPoint: endPoint, in: context, zoomScale: zoomScale)
            }
                       
    }
    
    
    
    func lineBetweenPoints(_ startPoint: CGPoint, _ endPoint: CGPoint) -> UIBezierPath {
        // Logic to draw an arrow between two points
        // This logic will draw a simple arrow, you might want to customize it further
        
        let arrowPath = UIBezierPath()
        arrowPath.move(to: startPoint)
        arrowPath.addLine(to: endPoint)
        
        // ... add arrowhead logic
        
        return arrowPath
    }
    
    func drawArrow(startPoint: CGPoint, endPoint: CGPoint, in context: CGContext,zoomScale: MKZoomScale) {
          // print("zoom : \(zoomScale)")
        if zoomScale > 0.1 {
            let arrowSize: CGFloat = 20.0 / zoomScale
            
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let length = sqrt(dx*dx + dy*dy)
            let angle = atan2(dy, dx)
            
            let arrowPath = UIBezierPath()
            arrowPath.move(to: endPoint)
            arrowPath.addLine(to: CGPoint(x: endPoint.x - arrowSize * cos(angle - .pi/6), y: endPoint.y - arrowSize * sin(angle - .pi/6)))
            arrowPath.addLine(to: CGPoint(x: endPoint.x - arrowSize * cos(angle + .pi/6), y: endPoint.y - arrowSize * sin(angle + .pi/6)))
            
            context.addPath(arrowPath.cgPath)
            context.fillPath()
        }
       }
    
    func polylineRenderer() -> MKPolylineRenderer? {
        print("trying polylineRenderer")
        if let overlay = overlay as? MKPolyline {
            print("polylineRenderer")
            let renderer = MKPolylineRenderer(polyline: overlay)
            renderer.lineWidth = 3.0
            renderer.strokeColor = UIColor.blue
            return renderer
        }
        return nil
    }
}
