import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == "com.zachfrew.project5.order" {
            let navController = window?.rootViewController as! UINavigationController
            let orderVC = navController.storyboard!.instantiateViewController(identifier: "OrderViewController") as! OrderViewController
            
            guard let intent = userActivity.interaction?.intent as? OrderIntent else {
                print("Received unknown intent")
                return true
            }

            guard let order = Order(from: intent) else {
                print("Received bad intent")
                return true
            }

            orderVC.cake = order.cake
            orderVC.toppings = order.toppings
            navController.pushViewController(orderVC, animated: true)
        }
        
        return true
    }
}
