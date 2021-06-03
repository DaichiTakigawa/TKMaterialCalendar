//
//  DrawerContentViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import Combine
import GoogleAPIClientForREST

class DrawerContentViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var calendars: [GTLRCalendar_CalendarListEntry] = []

    var userId: String {
        ""
    }

    func fetchCalendarList() {

    }

    func signOut() {

    }
}
