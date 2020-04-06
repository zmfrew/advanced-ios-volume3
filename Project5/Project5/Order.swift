import Foundation

struct Order: Codable, Hashable {
    let cake: Product
    let toppings: Set<Product>
    
    var intent: OrderIntent {
        let intent = OrderIntent()
        intent.cakeName = cake.name
        intent.toppings = toppings.map { $0.name.lowercased() }
        intent.suggestedInvocationPhrase = "Give me a \(cake.name) cupcake, or give me death!"
        return intent
    }
    
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

extension Order {
    init?(from data: Data?) {
        guard let data = data,
            let savedOrder = try? JSONDecoder().decode(Order.self, from: data) else { return nil }
        
        cake = savedOrder.cake
        toppings = savedOrder.toppings
    }
    
    init?(from intent: OrderIntent) {
        guard let cake = Menu.shared.findCake(from: intent.cakeName),
            let toppings = intent.toppings?.compactMap({ Menu.shared.findTopping(from: $0) }) else { return nil }
        
        self.cake = cake
        self.toppings = Set(toppings)
    }
}
