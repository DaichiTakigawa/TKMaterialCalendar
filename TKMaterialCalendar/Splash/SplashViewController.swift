//
//  SplashViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit
import Swinject
import SwinjectAutoregistration
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST

class SplashViewController: UIViewController {

    private let viewModel = DI.shared ~> SplashViewModel.self
    private let signIn = GIDSignIn.sharedInstance()!
    var rootNavigator: RootNavigator!

    override func viewDidLoad() {
        super.viewDidLoad()

        signIn.presentingViewController = self
        signIn.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        signIn.signIn()
    }

}

extension SplashViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("\(error.localizedDescription)")
            return
        }

        let query = GTLRCalendarQuery_CalendarListList.query()

        let service = GTLRCalendarService()
        service.authorizer = signIn.currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query) {  _, data, error in
            if let error = error {
                NSLog("\(error)")
            } else {
                if let calendarList = data as? GTLRCalendar_CalendarList, let items = calendarList.items {
                    items.forEach { item in
                        print(item.identifier ?? "nil")
                    }
                }
            }
        }
    }
}
