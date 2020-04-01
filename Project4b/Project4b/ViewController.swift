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
}
