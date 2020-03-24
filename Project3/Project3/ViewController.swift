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
    var targets = [UIImageView]()
    var currentTarget = 0
    var gunshot: AVAudioPlayer?
    var startTime = CACurrentMediaTime()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.scene.rootNode.addChildNode(face)
        sceneView.scene.rootNode.addChildNode(phone)
        face.addChildNode(leftEye)
        face.addChildNode(rightEye)
        
        let rowStackView = UIStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        rowStackView.distribution = .fillEqually
        rowStackView.axis = .vertical
        rowStackView.spacing = 20
        
        for _ in 1...6 {
            let colStackView = UIStackView()
            colStackView.translatesAutoresizingMaskIntoConstraints = false
            colStackView.distribution = .fillEqually
            colStackView.spacing = 20
            colStackView.axis = .horizontal
            
            rowStackView.addArrangedSubview(colStackView)
            
            for _ in 1...4 {
                let imageView = UIImageView(image: UIImage(named: "target"))
                imageView.contentMode = .scaleAspectFit
                imageView.alpha = 0
                
                targets.append(imageView)
                colStackView.addArrangedSubview(imageView)
            }
        }
        
        view.addSubview(rowStackView)
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            rowStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.bringSubviewToFront(reticule)
        targets.shuffle()
        
        perform(#selector(createTarget), with: nil, afterDelay: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    @objc func createTarget() {
        guard currentTarget < targets.count else {
            endGame()
            return
        }
        
        let target = targets[currentTarget]
        target.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.3) {
            target.transform = .identity
            target.alpha = 1
        }
        
        currentTarget += 1
    }
    
    @objc func finish() {
        dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func endGame() {
        let timeTaken = Int(CACurrentMediaTime() - startTime)
        let ac = UIAlertController(title: "Game over!", message: "You took \(timeTaken) seconds.", preferredStyle: .alert)
        present(ac, animated: true)
        
        perform(#selector(finish), with: nil, afterDelay: 3)
    }
    
    func fire() {
        let reticuleFrame = reticule.superview!.convert(reticule.frame, to: nil)
        
        let hitTargets = targets.filter { imageView in
            if imageView.alpha == 0 { return false }
            
            let ourFrame = imageView.superview!.convert(imageView.frame, to: nil)
            
            return ourFrame.intersects(reticuleFrame)
        }
        
        guard let selected = hitTargets.first else { return }
        
        selected.alpha = 0
        
        if let url = Bundle.main.url(forResource: "shot", withExtension: "wav") {
            gunshot = try? AVAudioPlayer(contentsOf: url)
            gunshot?.play()
        }
        
        perform(#selector(createTarget), with: nil, afterDelay: 1)
    }
    
    func update(using anchor: ARFaceAnchor) {
        if let leftBlink = anchor.blendShapes[.eyeBlinkLeft] as? Float,
            let rightBlink = anchor.blendShapes[.eyeBlinkRight] as? Float {
            if leftBlink > 0.1 && rightBlink > 0.1 {
                fire()
                return
            }
        }
        
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
