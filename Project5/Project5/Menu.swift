import Foundation

final class Menu {
    let cakes: [Product]
    let toppings: [Product]
    
    static let shared = Menu()
    
    private init() {
        cakes = Bundle.main.decode(from: "cupcakes.json")
        toppings = Bundle.main.decode(from: "toppings.json")
    }
    
    func findCake(from name: String?) -> Product? {
        cakes.first { $0.name == name }
    }
    
    func findTopping(from name: String?) -> Product? {
        toppings.first { $0.name.lowercased() == name }
    }
}
