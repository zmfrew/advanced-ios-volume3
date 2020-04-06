import UIKit

final class ToppingsViewController: UITableViewController {
    var cake: Product!
    var toppings = [Product]()
    var selectedToppings = Set<Product>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Toppings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Place Order", style: .plain, target: self, action: #selector(placeOrder))
        toppings = Menu.shared.toppings
    }
    
    @objc func placeOrder() {
        let orderVC = storyboard!.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        orderVC.cake = cake
        orderVC.toppings = selectedToppings
        navigationController?.pushViewController(orderVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toppings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let topping = toppings[indexPath.row]
        cell.textLabel?.text = "\(topping.name) - $\(topping.price)"
        cell.detailTextLabel?.text = topping.description
        
        if selectedToppings.contains(topping) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let topping = toppings[indexPath.row]
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            selectedToppings.remove(topping)
        } else {
            cell.accessoryType = .checkmark
            selectedToppings.insert(topping)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
