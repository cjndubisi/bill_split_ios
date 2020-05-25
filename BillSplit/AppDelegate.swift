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
    }

    guard isLoggedIn else { return authFlow(navigation: rootController) }

    homeFlow(navigation: rootController)
  }

  func authFlow(navigation: UINavigationController) {
    let authCoordinator = AuthenticationCoordinator(navigationController: navigation)

    children[String(describing: authCoordinator)] = authCoordinator
    // authenticated.
    authCoordinator.parentDelegate = { [weak self, unowned authCoordinator] in
      guard case .homeFlow = $0 else { return }
      self?.homeFlow(navigation: navigation)
      authCoordinator.finish?()
    }
    authCoordinator.finish = { [weak self, unowned authCoordinator] in
      self?.children[String(describing: authCoordinator)] = nil
    }

    authCoordinator.start()
  }

  func homeFlow(navigation: UINavigationController) {
    let homeCoordinator = HomeCoordinator(navigationController: navigation)

    children[String(describing: homeCoordinator)] = homeCoordinator

    // logout.
    homeCoordinator.parentDelegate = { [weak self, unowned homeCoordinator] in
      guard case .authFlow = $0 else { return }
      self?.authFlow(navigation: navigation)
      homeCoordinator.finish?()
    }
    homeCoordinator.finish = { [weak self, unowned homeCoordinator] in
      self?.children.removeValue(forKey: String(describing: homeCoordinator))
    }

    homeCoordinator.start()
  }
}

enum ApplicationCoordinatorDelegate {
  case authFlow
  case homeFlow
  case start(Scene) // Deep Link
}
