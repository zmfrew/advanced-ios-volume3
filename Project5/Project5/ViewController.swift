import UIKit

final class ViewController: UITableViewController {
    private var cakes = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cupcake Country"
        
        let url = Bundle.main.url(forResource: "cupcakes", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        cakes = try! JSONDecoder().decode([Product].self, from: data).sorted { $0.name < $1.name }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cake = cakes[indexPath.row]
        cell.textLabel?.text = "\(cake.name) - $\(cake.price)"
        cell.detailTextLabel?.text = cake.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toppingsVC = storyboard!.instantiateViewController(withIdentifier: "ToppingsViewController") as! ToppingsViewController
        toppingsVC.cake = cakes[indexPath.row]
        navigationController?.pushViewController(toppingsVC, animated: true)
    }
}
