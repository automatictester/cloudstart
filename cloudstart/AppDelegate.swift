import AWSAPIGateway
import AWSAuthCore
import AWSAuthUI
import AWSCore
import AWSMobileClient
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient initialized. Current UserState: \(userState.rawValue)")
            }
        }
        
        return AWSMobileClient
            .sharedInstance()
            .interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func doInvokeAPI() {
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2,
                                                           credentialsProvider: AWSMobileClient.sharedInstance())
        AWSAPI_HISVZWQOXC_CloudStartPoCClient.register(with: serviceConfiguration!, forKey: "USWest2AWSAPI_HISVZWQOXC_CloudStartPoCClient")
        
        let invocationClient = AWSAPI_HISVZWQOXC_CloudStartPoCClient(forKey: "USWest2AWSAPI_HISVZWQOXC_CloudStartPoCClient")
        
        invocationClient.rootGet().continueWith {(task: AWSTask) -> AnyObject? in
            self.showResult(task: task)
            return nil
        }
    }
    
    func showResult(task: AWSTask<AnyObject>) {
        if let error = task.error {
            print("Error: \(error)")
        } else if let result = task.result {
            if result is AWSAPI_HISVZWQOXC_Result {
                let res = result as! AWSAPI_HISVZWQOXC_Result
                print(String(format:"%@ %@", res.body, res.statusCode))
            } else if result is NSDictionary {
                let res = result as! NSDictionary
                print("NSDictionary: \(res)")
            }
        }
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        self.doInvokeAPI()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
