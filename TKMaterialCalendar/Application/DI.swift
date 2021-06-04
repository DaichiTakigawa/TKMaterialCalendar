//
//  DI.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import Foundation
import Swinject
import SwinjectAutoregistration
import GoogleSignIn
import GoogleAPIClientForREST

// swiftlint:disable type_name
enum DI {

    private(set) static var shared: Container = {
        let container = Container()

        container.register(GIDSignIn.self) { _ in
            GIDSignIn.sharedInstance()
        }
        container.register(GTLRCalendarService.self) { _ in
            GTLRCalendarService()
        }.inObjectScope(.container) // for singleton

        container.register(SplashViewModel.self) { resolver in
            SplashViewModel(signIn: resolver~>, service: resolver~>)
        }

        container.register(DrawerContentViewModel.self) { resolver in
            DrawerContentViewModel(signIn: resolver~>, service: resolver~>)
        }

        container.register(MonthViewViewModel.self) { resolver in
            MonthViewViewModel(repository: resolver~>)
        }
        container.register(MonthViewRepository.self) { resolver in
            MonthViewRepository(service: resolver~>)
        }

        return container
    }()

    #if DEBUG
    // for test
    static func replaceShared(container: Container) {
        DI.shared = container
    }
    #endif
}

// swiftlint:enable type_name
