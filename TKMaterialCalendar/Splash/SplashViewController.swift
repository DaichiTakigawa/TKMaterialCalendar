//
//  SplashViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit
import Combine
import Swinject
import SwinjectAutoregistration

class SplashViewController: UIViewController {

    private let viewModel = DI.shared ~> SplashViewModel.self
    private var cancellables = Set<AnyCancellable>()
    var rootNavigator: RootNavigator!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.signIn(presentingViewController: self)
    }

    private func setupObservers() {
        viewModel.$loginState.sink { [weak self] loginState in
            switch loginState {
            case .success:
                self?.rootNavigator.navigateTo(destination: .main)
            default:
                break
            }
        }
        .store(in: &cancellables)
    }

}
