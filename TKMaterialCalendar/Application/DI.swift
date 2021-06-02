//
//  DI.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import Foundation
import Swinject
import SwinjectAutoregistration
import Moya

// swiftlint:disable type_name
enum DI {

    private(set) static var shared: Container = {
        let container = Container()

        container.register(SplashViewModel.self) { _ in
            SplashViewModel()
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
