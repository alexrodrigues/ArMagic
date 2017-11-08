/*
 
 Author: user2068754
 From: https://stackoverflow.com/questions/47149669/how-to-detect-if-a-specific-scnnode-is-located-inside-another-scnnodes-bounding
 
 */

import UIKit
import ARKit

extension SCNNode {
    func boundingBoxContains(point: SCNVector3, in node: SCNNode) -> Bool {
        let localPoint = self.convertPosition(point, from: node)
        return boundingBoxContains(point: localPoint)
    }
    
    func boundingBoxContains(point: SCNVector3) -> Bool {
        return BoundingBox(self.boundingBox).contains(point)
    }
}


struct BoundingBox {
    let min: SCNVector3
    let max: SCNVector3
    
    init(_ boundTuple: (min: SCNVector3, max: SCNVector3)) {
        min = boundTuple.min
        max = boundTuple.max
    }
    
    func contains(_ point: SCNVector3) -> Bool {
        let contains =
            min.x <= point.x &&
                min.y <= point.y &&
                min.z <= point.z &&
                
                max.x > point.x &&
                max.y > point.y &&
                max.z > point.z
        
        return contains
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}
func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}
