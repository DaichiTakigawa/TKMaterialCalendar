//
//  DrawerContentViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import Combine
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST

class DrawerContentViewModel: ObservableObject {

    private let signIn: GIDSignIn
    private let service: GTLRCalendarService
    @Published var calendars: [GTLRCalendar_CalendarListEntry] = []

    var userId: String? {
        signIn.currentUser.profile.email
    }

    init(signIn: GIDSignIn, service: GTLRCalendarService) {
        self.signIn = signIn
        self.service = service
    }

    func fetchCalendarList() {
        let query = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(query) { [weak self] _, data, error in
            if let error = error {
                logger.error("\(error.localizedDescription)")
            } else {
                if let data = data as? GTLRCalendar_CalendarList, let items = data.items {
                    self?.calendars = items
                }
            }
        }
    }
}
