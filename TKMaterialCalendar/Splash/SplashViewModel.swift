//
//  SplashViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit
import Combine
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST
import RealmSwift

class SplashViewModel: NSObject, ObservableObject {

    enum LoginState {
        case initial
        case success
        case failure
    }

    private let signIn: GIDSignIn
    private let service: GTLRCalendarService
    @Published var loginState: LoginState = .initial

    init(signIn: GIDSignIn, service: GTLRCalendarService) {
        self.signIn = signIn
        self.service = service
    }

    func signIn(presentingViewController: UIViewController) {
        signIn.presentingViewController = presentingViewController
        signIn.delegate = self
        if signIn.hasPreviousSignIn() {
            // 以前のログイン情報が残っていたら復元する
            signIn.restorePreviousSignIn()
        } else {
            // 通常のログインを実行
            signIn.signIn()
        }
    }

}

extension SplashViewModel: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            logger.error("\(error.localizedDescription)")
            self.loginState = .failure
        } else {
            service.authorizer = signIn.currentUser.authentication.fetcherAuthorizer()
            loginState = .success
        }
    }
}
