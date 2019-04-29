import MapKit

class ClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
        self.canShowCallout = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let cluster = annotation as? MKClusterAnnotation {

            let totalAnnotations = cluster.memberAnnotations.count
            
            let redcount = count(colour: .red)
            let ambercount = count(colour: .amber)
            let greencount = count(colour: .green)

            image = drawClusterImage(red: CGFloat(redcount), amber: CGFloat(ambercount), green: CGFloat(greencount), total: CGFloat(totalAnnotations))
        }
    }

    private func drawClusterImage(red: CGFloat, amber: CGFloat, green: CGFloat, total: CGFloat) -> UIImage {
        let totalPins = total
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image { _ in
            // Fill full circle with wholeColor
            UIColor.init(white: 30/255, alpha: 1).setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
            
            // Fill pie with fractionColor
            UIColor(named: "pinGreen")!.setFill()
            let greenPath = UIBezierPath()
            greenPath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                           startAngle: -CGFloat.pi/2,
                           endAngle: (CGFloat.pi * 2.0 * green / totalPins)-CGFloat.pi/2,
                           clockwise: true)
            greenPath.addLine(to: CGPoint(x: 20, y: 20))
            greenPath.close()
            greenPath.fill()
            
            UIColor(named: "pinAmber")!.setFill()
            let amberPath = UIBezierPath()
            amberPath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                             startAngle: (CGFloat.pi * 2.0 * green / totalPins)-CGFloat.pi/2,
                             endAngle: (CGFloat.pi * 2.0 * (amber + green) / totalPins)-CGFloat.pi/2,
                             clockwise: true)
            amberPath.addLine(to: CGPoint(x: 20, y: 20))
            amberPath.close()
            amberPath.fill()
            
            
            UIColor(named: "pinRed")!.setFill()
            let redPath = UIBezierPath()
            redPath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                             startAngle: (CGFloat.pi * 2.0 * (amber+green) / totalPins)-CGFloat.pi/2,
                             endAngle: (CGFloat.pi * 2.0 * (red+green+amber) / totalPins)-CGFloat.pi/2,
                             clockwise: true)
            redPath.addLine(to: CGPoint(x: 20, y: 20))
            redPath.close()
            redPath.fill()

            // Fill inner circle with white color
            UIColor.init(white: 30/255, alpha: 1).setFill()
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()

            // Finally draw count text vertically and horizontally centered
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            let text = "\(Int(totalPins))"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }

    private func count(colour colourType: evStationAnnotation.colour) -> Int {
        guard let cluster = annotation as? MKClusterAnnotation else {
            return 0
        }
        return cluster.memberAnnotations.filter { member -> Bool in
            guard let PINannotation = member as? evStationAnnotation else {
                fatalError("Found unexpected annotation type")
            }
            return PINannotation.colour == colourType
        }.count
    }
}
