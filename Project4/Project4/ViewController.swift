import UIKit
import SceneKit
import ARKit

enum MathOperations: CaseIterable {
    case add, multiply
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var question: UILabel!
    @IBOutlet private weak var correct: UIImageView!
    
    private var answer: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Numbers", bundle: nil) else { fatalError() }
        
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 2
        
        sceneView.session.run(configuration)
    }
    
    func askQuestion() {
        let newQuestion = createUniqueQuestion()
        question.text = newQuestion.text
        answer = newQuestion.answer
        
        question.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.question.alpha = 1
            
            self.correct.alpha = 0
            self.correct.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }
    }
    
    func correctAnswer() {
        correct.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        UIView.animate(withDuration: 0.5) {
            self.correct.transform = .identity
            self.correct.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.askQuestion()
        }
    }
    
    func createUniqueQuestion() -> (text: String, answer: Int) {
        let operation = MathOperations.allCases.randomElement()!
        var question: String
        var answer: Int
        
        repeat {
            switch operation {
            case .add:
                let firstNumber = Int.random(in: 1...50)
                let secondNumber = Int.random(in: 1...49)
                
                question = "What is \(firstNumber) + \(secondNumber)?"
                answer = firstNumber + secondNumber
                
            case .multiply:
                let firstNumber = Int.random(in: 1...10)
                let secondNumber = Int.random(in: 1...9)
                
                question = "What is \(firstNumber) times \(secondNumber)?"
                answer = firstNumber * secondNumber
            }
        } while !answer.hasUniqueDigits
        
        return (question, answer)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let anchors = sceneView.session.currentFrame?.anchors else { return }
        
        let visibleAnchors = anchors.filter {
            guard let anchor = $0 as? ARImageAnchor else { return false }
            return anchor.isTracked
        }
        
        let nodes = visibleAnchors.sorted { anchor1, anchor2 -> Bool in
            guard let node1 = sceneView.node(for: anchor1) else { return false }
            guard let node2 = sceneView.node(for: anchor1) else { return false }
            return node1.worldPosition.x < node2.worldPosition.x
        }
        
        let combined = nodes.reduce("") { $0 + ($1.name ?? "")}
        let userAnswer = Int(combined) ?? 0
        
        if userAnswer == answer {
            answer = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.correctAnswer()
            }
        }
    }
}
