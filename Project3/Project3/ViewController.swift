import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var reticule: UIImageView!
    
    let face = SCNNode()
    let leftEye = Eye(color: .red)
    let rightEye = Eye(color: .blue)
    let phone = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    let smoothingAmount = 20
    var eyeLookHistory = ArraySlice<CGPoint>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.scene.rootNode.addChildNode(face)
        sceneView.scene.rootNode.addChildNode(phone)
        face.addChildNode(leftEye)
        face.addChildNode(rightEye)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func update(using anchor: ARFaceAnchor) {
        leftEye.simdTransform = anchor.leftEyeTransform
        rightEye.simdTransform = anchor.rightEyeTransform
        
        let points = [leftEye, rightEye].compactMap { eye -> CGPoint?  in
            let hitTest = phone.hitTestWithSegment(from: eye.target.worldPosition, to: eye.worldPosition)
            return hitTest.first?.screenPosition
        }
        
        guard let leftPoint = points.first, let rightPoint = points.last else { return }
        
        let centerPoint = CGPoint(x: (leftPoint.x + rightPoint.x) / 2, y: -(leftPoint.y + rightPoint.y) / 2)
        reticule.transform = eyeLookHistory.averageTransform
        
        eyeLookHistory.append(centerPoint)
        eyeLookHistory = eyeLookHistory.suffix(smoothingAmount)
    }
}

extension ViewController: ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        DispatchQueue.main.async {
            self.face.simdTransform = node.simdTransform
            self.update(using: faceAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = sceneView.pointOfView?.simdTransform else { return }
        phone.simdTransform = pov
    }
}

extension SCNHitTestResult {
    var screenPosition: CGPoint {
        let physicalSize = CGSize(width: 0.062 / 2, height: 0.135 / 2)
        let screenResolution = UIScreen.main.bounds.size
        let screenX = CGFloat(localCoordinates.x) / physicalSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}

extension Collection where Element == CGPoint {
    var averageTransform: CGAffineTransform {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for item in self {
            x += item.x
            y += item.y
        }
        
        let floatCount = CGFloat(count)
        return CGAffineTransform(translationX: x / floatCount, y: y / floatCount)
    }
}
