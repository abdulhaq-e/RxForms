//
//  AppDelegate.swift
//  TestApp
//
//  Created by Abdulhaq Emhemmed on 7/8/19.
//  Copyright © 2019 Umbrella Financial Services LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
      window = UIWindow(frame: UIScreen.main.bounds)
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.window = window!
      window?.makeKeyAndVisible()
      return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
      window?.rootViewController = ViewController()
      return true
  }
}

