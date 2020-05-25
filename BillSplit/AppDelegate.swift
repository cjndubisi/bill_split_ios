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
  var appCoordinator: ApplicationCoordinator!
  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {


    NVActivityIndicatorView.DEFAULT_TYPE = .circleStrokeSpin
    NVActivityIndicatorView.DEFAULT_COLOR = .blue
    NVActivityIndicatorView.DEFAULT_TEXT_COLOR = .white

    appCoordinator = ApplicationCoordinator(window: UIWindow(frame: UIScreen.main.bounds))
    appCoordinator.start()

    return true
  }
}

class ApplicationCoordinator: Coordinator {
  var finish: (() -> Void)!
  let window: UIWindow

  private(set) var children: [String: Coordinator] = [:]

  init(window: UIWindow) {
    self.window = window
  }

  var isLoggedIn: Bool {
    return !(UserDefaults.standard.string(forKey: Constants.tokenKey)?.isEmpty ?? true)
  }

  func start() {
    let rootController = UINavigationController()

    defer {
      window.rootViewController = rootController
      window.makeKeyAndVisible()
      print(children)
    }

    guard isLoggedIn else {
      let authCoordinator = AuthenticationCoordinator(navigationController: rootController)
      authCoordinator.start()

      children[String(describing: authCoordinator)] = authCoordinator
      authCoordinator.finish = { [weak self, unowned authCoordinator] in
        self?.children.removeValue(forKey: String(describing: authCoordinator))
      }
      return
    }
    let homeCoordinator = HomeCoordinator(navigationController: rootController)
    children[String(describing: homeCoordinator)] = homeCoordinator
    homeCoordinator.finish = { [weak self, unowned homeCoordinator] in
      self?.children.removeValue(forKey: String(describing: homeCoordinator))
    }
  }
}
