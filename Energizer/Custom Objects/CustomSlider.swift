//
//  CustomSlider.swift
//  GetAPI
//
//  Created by Michalis Neophytou on 08/02/2019.
//  Copyright © 2019 Michalis Neophytou. All rights reserved.
//

import Foundation
import UIKit

class CustomSlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    @IBInspectable open var trackWidth:CGFloat = 6 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}
