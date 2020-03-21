import UIKit
import SceneKit

class Eye: SCNNode {
    let target = SCNNode()
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented.")
    }
    
    init(color: UIColor) {
        super.init()
        
        let geometry = SCNCylinder(radius: 0.005, height: 0.2)
        geometry.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: geometry)
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        node.opacity = 0.5
        
        addChildNode(node)
        addChildNode(target)
        
        target.position.z = 1
    }
}
