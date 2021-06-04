//
//  DrawerContentViewModelMock.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

#if DEBUG
import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

class DrawerContentViewModelMock: DrawerContentViewModel {

    private(set) var userIdSetCallCount = 0
    private var _userId: String?
    override var userId: String? {
        get {
            _userId
        }
        set {
            _userId = newValue
            userIdSetCallCount += 1
        }
    }

    private(set) var fetchCalendarListCallCount = 0
    var fetchCalendarListHandler: (() -> Void)?

    init() {
        super.init(signIn: GIDSignIn.sharedInstance(), service: GTLRCalendarService())
    }

    override func fetchCalendarList() {
        fetchCalendarListCallCount += 1
        if let fetchCalendarListHandler = fetchCalendarListHandler {
            fetchCalendarListHandler()
        }

    }
}

#endif
