//
//  AppDelegate.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import NVActivityIndicatorView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Override point for customization after application launch.
    let navigationController = UINavigationController()
    let authCoordinator = AuthenticationCoordinator(navigationController: navigationController)

    NVActivityIndicatorView.DEFAULT_TYPE = .circleStrokeSpin
    NVActivityIndicatorView.DEFAULT_COLOR = .blue
    NVActivityIndicatorView.DEFAULT_TEXT_COLOR = .white

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    authCoordinator.start()

    return true
  }
}
