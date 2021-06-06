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
    @Published var events: [Event]?

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

        var idToColor: [String: UIColor] = [:]
        colorDefinitions.forEach { colorDefinition in
            idToColor[colorDefinition.id] = colorDefinition.getBackgroundUIColor()!
        }

        let start = getStartDate(targetMonth)
        let end = getEndDate(targetMonth)
        let publishers = calendars.map { calendar in
            repository.fetchEvents(calendarId: calendar.id, start: start, end: end)
                .map { events -> [Event] in
                    events.map { event in
                        guard let id = event.identifier, let label = event.summary else {
                            return nil
                        }
                        var color: UIColor?
                        if let colorId = event.colorId {
                            color = idToColor[colorId]
                        }
                        if color == nil, let colorId = calendar.colorId {
                            color = idToColor[colorId]
                        }
                        var startDate: Date?
                        var endDate: Date?
                        if let start = event.start?.date?.date {
                            startDate = start
                            endDate = event.end?.date?.date.toPrevDate()
                        }
                        if let start = event.start?.dateTime?.date {
                            startDate = start
                            endDate = event.end?.dateTime?.date
                        }
                        guard let startDate = startDate, let endDate = endDate else {
                            return nil
                        }
                        return Event(id: id, label: label, color: color ?? .red, startDate: startDate, endDate: endDate)
                    }
                    .compactMap {
                        $0
                    }
                }
        }

        Publishers.MergeMany(publishers)
            .collect()
            .map { result -> [Event] in
                result.flatMap {
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
    private func getStartDate(_ targetMonth: String) -> Date {
        DateUtils.firstDayOfCalendar(yearMonth: targetMonth, startDayOfWeek: .sunday)
    }

    private func getEndDate(_ targetMonth: String) -> Date {
        let firstDay = DateUtils.firstDayOfCalendar(yearMonth: targetMonth, startDayOfWeek: .sunday)
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: (6 * 7) - 1, to: firstDay)!
    }
}
