//
//  MonthViewModel.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import Combine
import RealmSwift
import GoogleSignIn
import GoogleAPIClientForREST

class MonthViewViewModel: ObservableObject {

    private static var shouldSyncWithServer = true

    private let repository: MonthViewRepository
    private var cancellables = Set<AnyCancellable>()
    @Published var events: [Event] = []

    init(repository: MonthViewRepository) {
        self.repository = repository
    }

    func setup(targetMonth: String) {
        repository.getCalendarsPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(.failure(error)):
                    logger.error("\(error.localizedDescription)")
                default:
                    break
                }
            }, receiveValue: { [weak self] calendars in
                if !calendars.isEmpty {
                    self?.fetchEvents(targetMonth: targetMonth)
                }
            })
            .store(in: &cancellables)

        repository.getColorDefinitionsPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(.failure(error)):
                    logger.error("\(error.localizedDescription)")
                default:
                    break
                }
            }, receiveValue: { [weak self] colorDefinitions in
                if !colorDefinitions.isEmpty {
                    self?.fetchEvents(targetMonth: targetMonth)
                }
            })
            .store(in: &cancellables)

        if Self.shouldSyncWithServer {
            repository.syncWithServer()
            Self.shouldSyncWithServer = false
        }
    }

    func fetchEvents(targetMonth: String) {
        let realm = try! Realm()
        let calendars = CalendarEntity.getAll(in: realm)
        let colorDefinitions = ColorDefinition.getAll(in: realm)

        if calendars.isEmpty || colorDefinitions.isEmpty {
            return
        }

        let start = getStartDate(targetMonth)
        let end = getEndDate(targetMonth)
        let publishers = calendars.map { calendar in
            repository.fetchEvents(calendarId: calendar.id, start: start, end: end)
        }

        Publishers.MergeMany(publishers)
            .collect()
            .map { result -> [Event] in
                result.flatMap {
                    $0
                }
                .map { event in
                    guard let id = event.identifier,
                          let label = event.summary,
                          let color = colorDefinitions.first(where: {
                            $0.id == event.colorId
                          })?.getBackgroundUIColor(),
                          let startDate = event.start?.date?.date ?? event.start?.dateTime?.date,
                          let endDate = event.end?.date?.date ?? event.end?.dateTime?.date else {
                        return nil
                    }
                    return Event(id: id, label: label, color: color, startDate: startDate, endDate: endDate)
                }
                .compactMap {
                    $0
                }

            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    logger.error("failed to fetch events")
                default:
                    break
                }
            }, receiveValue: { [weak self] events in
                self?.events = events
            })
            .store(in: &cancellables)
    }

}

extension MonthViewViewModel {
    func getStartDate(_ targetMonth: String) -> Date {
        DateUtils.getDateListOfMonth(yearMonth: targetMonth, startDayOfWeek: .sunday).first!.toDate(format: "yyyy/MM/dd")
    }

    func getEndDate(_ targetMonth: String) -> Date {
        DateUtils.getDateListOfMonth(yearMonth: targetMonth, startDayOfWeek: .sunday).last!.toDate(format: "yyyy/MM/dd")
    }
}
