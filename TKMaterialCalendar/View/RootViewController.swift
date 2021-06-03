//
//  RootViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit

class RootViewController: UIViewController, RootNavigatorDelegate {

    private var current: UIViewController!
    private var rootNavigator = RootNavigator()

    init() {
        super.init(nibName: nil, bundle: nil)
        rootNavigator.delegate = self
        current = createSplashViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(current)
        view.addSubview(current.view)
        current.view.translatesAutoresizingMaskIntoConstraints = false
        setupFullScreenConstraints(superView: view, subView: current.view)
        current.didMove(toParent: self)
    }

    func navigateToSplashViewController() {
        let splashViewController = createSplashViewController()
        animateFadeTransition(to: splashViewController)
    }

    func navigateToMainViewController() {
        // initialize drawer container
        let drawerWidth = min(300, UIScreen.main.bounds.width - 40)
        let drawerContainer = DrawerContainerController(drawerWidth: drawerWidth)

        let calendarViewController = CalendarViewController(rootNavigator: rootNavigator)
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        let drawerContentViewController = DrawerContentViewController(rootNavigator: rootNavigator)

        // mediate
        drawerContainer.drawerViewController = drawerContentViewController
        drawerContainer.mainViewController = navigationController
        animateFadeTransition(to: drawerContainer)
    }

    func setDrawerState(isOpen: Bool) {
        if let drawerContainer = current as? DrawerContainerController {
            if isOpen {
                drawerContainer.setDrawerState(.opened, animated: true)
            } else {
                drawerContainer.setDrawerState(.closed, animated: true)
            }
        }
    }

    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        transition(from: current,
                   to: new,
                   duration: 0.3,
                   options: [.transitionCrossDissolve, .curveEaseOut],
                   animations: { [unowned self] in
                    view.addSubview(new.view)
                    new.view.translatesAutoresizingMaskIntoConstraints = false
                    setupFullScreenConstraints(superView: view, subView: new.view)
                   }, completion: { [unowned self] _ in
                    current.view.removeFromSuperview()
                    current.removeFromParent()
                    new.didMove(toParent: self)
                    current = new
                    completion?()
                   })
    }

    private func createSplashViewController() -> SplashViewController {
        let splashStoryboard = R.storyboard.splash()
        let splashViewController = splashStoryboard.instantiateInitialViewController()! as SplashViewController
        splashViewController.rootNavigator = rootNavigator
        return splashViewController
    }

}

extension RootViewController {
    func setupFullScreenConstraints(superView: UIView, subView: UIView) {
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: superView.topAnchor),
            subView.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            subView.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
            subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor)
        ])
    }
}
