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
        let activity = NSUserActivity(activityType: "com.zachfrew.project5a.order")
        
        let orderName = order.name
        if ["A", "E", "I", "O", "U"].contains(orderName.first) {
            activity.title = "Order an \(orderName)."
        } else {
            activity.title = "Order a \(orderName)."
        }
        
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        if let orderData = try? JSONEncoder().encode(order) {
            activity.userInfo = ["order": orderData]
        }
        
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(order.name)
        
        activity.suggestedInvocationPhrase = "I need a cupcake!"
        
        userActivity = activity
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
