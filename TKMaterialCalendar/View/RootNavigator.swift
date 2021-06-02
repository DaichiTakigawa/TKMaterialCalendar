//
//  RootNavigator.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import Foundation

protocol RootNavigatorDelegate: AnyObject {
    func navigateToSplashViewController()
    func navigateToMainViewController()
    func setDrawerState(isOpen: Bool)
}

class RootNavigator {
    weak var delegate: RootNavigatorDelegate?

    enum Destination {
        case splash
        case main
    }

    func navigateTo(destination: Destination) {
        switch destination {
        case .splash:
            delegate?.navigateToSplashViewController()
        case .main:
            delegate?.navigateToMainViewController()
        }
    }

    func setDrawerState(isOpen: Bool) {
        delegate?.setDrawerState(isOpen: isOpen)
    }
}
