import UIKit

final class ToppingsViewController: UITableViewController {
    var cake: Product!
    var toppings = [Product]()
    var selectedToppings = Set<Product>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Toppings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Place Order", style: .plain, target: self, action: #selector(placeOrder))
        let url = Bundle.main.url(forResource: "toppings", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        toppings = try! JSONDecoder().decode([Product].self, from: data).sorted { $0.name < $1.name }
    }
    
    @objc func placeOrder() {
        
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
