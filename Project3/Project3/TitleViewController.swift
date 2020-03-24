import UIKit

final class TitleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let vc = storyboard?.instantiateViewController(identifier: "ViewController") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
