import Foundation

struct Order: Codable, Hashable {
    let cake: Product
    let toppings: Set<Product>
    
    var name: String {
        if toppings.count == 0 {
            return cake.name
        } else {
            let toppingNames = toppings.map { $0.name.lowercased() }
            return "\(cake.name), \(toppingNames.joined(separator: ", "))."
        }
    }
    
    var price: Int {
        toppings.reduce(cake.price) { $0 + $1.price }
    }
}
