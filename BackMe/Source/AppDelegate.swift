//
//  AppDelegate.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/12/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var completionHandler: (() -> Void)?

    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let navigationController = window?.rootViewController as? UINavigationController,
            let viewController = navigationController.topViewController as? WeatherForecastViewController else {
                
                return
        }
        
        viewController.loadForecast()
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        
        self.completionHandler = completionHandler
    }
}
