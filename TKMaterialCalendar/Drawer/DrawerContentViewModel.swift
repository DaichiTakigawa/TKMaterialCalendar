//
//  DrawerContentViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import Combine
import RealmSwift
import GoogleSignIn

class DrawerContentViewModel: ObservableObject {

    private let signIn: GIDSignIn
    private var cancellables = Set<AnyCancellable>()
    @Published var calendars: [CalendarEntity] = []

    var userId: String? {
        signIn.currentUser.profile.email
    }

    init(signIn: GIDSignIn) {
        self.signIn = signIn
    }

    func searchCalendars() {
        let realm = try! Realm()
        let calendars = realm.objects(CalendarEntity.self)
        return calendars.collectionPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    logger.error("\(error.localizedDescription)")
                default:
                    break
                }
            }, receiveValue: { [weak self] result in
                self?.calendars = Array(result)
            })
            .store(in: &cancellables)
    }
}
