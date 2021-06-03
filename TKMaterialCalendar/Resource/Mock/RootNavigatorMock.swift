//
//  RootNavigatorMock.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

#if DEBUG

import Foundation

class RootNavigatorMock: RootNavigator {

    private(set) var delegateSetCallCount = 0
    override var delegate: RootNavigatorDelegate? { didSet { delegateSetCallCount += 1 } }

    private(set) var navigateToCallCount = 0
    var navigateToHandler: ((Destination) -> Void)?
    override func navigateTo(destination: Destination) {
        navigateToCallCount += 1
        if let navigateToHandler = navigateToHandler {
            navigateToHandler(destination)
        }

    }

    private(set) var setDrawerStateCallCount = 0
    var setDrawerStateHandler: ((Bool) -> Void)?
    override func setDrawerState(isOpen: Bool) {
        setDrawerStateCallCount += 1
        if let setDrawerStateHandler = setDrawerStateHandler {
            setDrawerStateHandler(isOpen)
        }

    }
}

#endif
