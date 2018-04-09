//
//  CommonDataHelper.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 29/03/2018.
//  Copyright © 2018 Gregory Qian. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage

class CommonDataHelper {
    class func cgPointToCIVector(point: CGPoint, baseSize: CGSize) -> CIVector {
        let y = baseSize.height - point.y
        return CIVector(x: point.x, y: y)
    }
}

extension CGPoint {
    func cgPointToCIVector(point: CGPoint, baseSize: CGSize) -> CIVector {
        let y = baseSize.height - point.y
        return CIVector(x: point.x, y: y)
    }
}
