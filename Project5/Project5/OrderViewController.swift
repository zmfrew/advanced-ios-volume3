import Intents
import UIKit

final class OrderViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var details: UILabel!
    @IBOutlet private weak var cost: UILabel!
    
    var cake: Product!
    var toppings = Set<Product>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hack to get around image being blue in IB but black in assets.
        let image = imageView.image
        imageView.image = nil
        imageView.image = image
        
        let newOrder = Order(cake: cake, toppings: toppings)
        showDetails(newOrder)
        send(newOrder)
        donate(newOrder)
        
        title = "All set!"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    @objc func done() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func donate(_ order: Order) {
        let interaction = INInteraction(intent: order.intent, response: nil)
        
        interaction.donate { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func send(_ order: Order) {
        do {
            let data = try JSONEncoder().encode(order)
            print(data)
        } catch {
            print("Failed to create an order.")
        }
    }
    
    func showDetails(_ order: Order) {
        details.text = order.name
        cost.text = "$\(order.price)"
    }
}
