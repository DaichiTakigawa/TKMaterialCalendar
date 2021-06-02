//
//  SplashViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit
import Combine
import GoogleSignIn

class SplashViewModel: NSObject, ObservableObject {

    enum LoginState {
        case initial
        case success
        case failure
    }
    @Published var loginState: LoginState = .initial

    func signIn(presentingViewController: UIViewController) {
        guard let signIn = GIDSignIn.sharedInstance() else {
            logger.debug("fail to get GIDSignIn instance")
            return
        }
        signIn.presentingViewController = presentingViewController
        signIn.delegate = self
        signIn.signIn()
    }
}

extension SplashViewModel: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            logger.error("\(error.localizedDescription)")
            self.loginState = .failure
        } else {
            self.loginState = .success
        }
    }
}
