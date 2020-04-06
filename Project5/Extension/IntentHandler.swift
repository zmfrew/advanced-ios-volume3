import Intents

final class IntentHandler: INExtension, OrderIntentHandling {
    func confirm(intent: OrderIntent, completion: @escaping (OrderIntentResponse) -> Void) {
        let response = OrderIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }

    func handle(intent: OrderIntent, completion: @escaping (OrderIntentResponse) -> Void) {
        guard let order = Order(from: intent) else {
            completion(OrderIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        let response = OrderIntentResponse(code: .success, userActivity: nil)
        response.cakeName = intent.cakeName
        response.preparationTime = NSNumber(value: 5 + order.toppings.count)
        
        completion(response)
    }
    
    func resolveCakeName(for intent: OrderIntent, with completion: @escaping (INStringResolutionResult) -> Void) { }
    
    func resolveToppings(for intent: OrderIntent, with completion: @escaping ([INStringResolutionResult]) -> Void) { }
}
