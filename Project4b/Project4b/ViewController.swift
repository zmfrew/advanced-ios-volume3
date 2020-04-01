import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet private var sceneView: ARSCNView!
    
    var paintings = [String: Painting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        loadData()
        
        let preload = UIWebView()
        view.addSubview(preload)
        let request = URLRequest(url: URL(string: "https://en.wikipedia.org/wiki/Mona_Lisa")!)
        preload.loadRequest(request)
        preload.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Paintings", bundle: nil) else { fatalError() }
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration)
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "paintings", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let loadedPaintings = try? JSONDecoder().decode([String: Painting].self, from: data) else { fatalError() }
        
        paintings = loadedPaintings
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let paintingName = imageAnchor.referenceImage.name else { return nil }
        guard let painting = paintings[paintingName] else { return nil }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        let spacing: Float = 0.005
        let titleNode = textNode(painting.title, font: UIFont.boldSystemFont(ofSize: 10))
        titleNode.pivotOnTopLeft()
        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2)
        
        planeNode.addChildNode(titleNode)
        
        return node
    }
    
    func textNode(_ str: String, font: UIFont) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0.0)
        text.flatness = 0.1
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        return textNode
    }
}
