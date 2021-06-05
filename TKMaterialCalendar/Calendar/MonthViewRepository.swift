//
//  MonthRepository.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/04.
//

import Foundation
import Combine
import RealmSwift
import GoogleAPIClientForREST

class MonthViewRepository {

    enum MonthViewError: Error {
        case failure(underlying: Error)
    }

    private let service: GTLRCalendarService

    init(service: GTLRCalendarService) {
        self.service = service
    }

    private func fetchCalendars() {
        let query = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(query) { _, data, error in
            if let error = error {
                logger.error("\(error.localizedDescription)")
            } else {
                if let data = data as? GTLRCalendar_CalendarList, let items = data.items {
                    do {
                        let realm = try Realm()
                        try items.forEach { c in
                            let calendar = CalendarEntity()
                            calendar.populate(from: c)
                            try realm.write {
                                realm.add(calendar, update: .modified)
                            }
                        }
                    } catch {
                        logger.error("\(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func fetchColorDefinitions() {
        let query = GTLRCalendarQuery_ColorsGet.query()
        service.executeQuery(query) { _, data, error in
            if let error = error {
                logger.error("\(error.localizedDescription)")
            } else {
                if let data = data as? GTLRCalendar_Colors, let items = data.calendar?.additionalProperties() {
                    do {
                        let realm = try Realm()
                        try items.forEach { key, definition in
                            let colorDefinition = ColorDefinition()
                            colorDefinition.populate(id: key, color: definition as! GTLRCalendar_ColorDefinition)
                            try realm.write {
                                realm.add(colorDefinition, update: .modified)
                            }
                        }
                    } catch {
                        logger.error("\(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func fetchEvents(calendarId: String, start: Date, end: Date) -> AnyPublisher<[GTLRCalendar_Event], MonthViewError> {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        query.timeMin = GTLRDateTime(date: start)
        query.timeMax = GTLRDateTime(date: end)
        let future = Future<[GTLRCalendar_Event], MonthViewError> { [weak self] promise in
            self?.service.executeQuery(query) { _, data, error in
                if let error = error {
                    logger.error("\(error.localizedDescription)")
                    promise(.failure(.failure(underlying: error)))
                } else {
                    if let data = data as? GTLRCalendar_Events, let items = data.items {
                        promise(.success(items))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        return future
    }

    func getCalendarsPublisher() -> AnyPublisher<[CalendarEntity], MonthViewError> {
        let realm = try! Realm()
        let calendars = realm.objects(CalendarEntity.self)
        return calendars.collectionPublisher
            .map { result -> [CalendarEntity] in
                Array(result)
            }
            .mapError { error -> MonthViewError in
                MonthViewError.failure(underlying: error)
            }
            .eraseToAnyPublisher()
    }

    func getColorDefinitionsPublisher() -> AnyPublisher<[ColorDefinition], MonthViewError> {
        let realm = try! Realm()
        let calendars = realm.objects(ColorDefinition.self)
        return calendars.collectionPublisher
            .map { result -> [ColorDefinition] in
                Array(result)
            }
            .mapError { error -> MonthViewError in
                MonthViewError.failure(underlying: error)
            }
            .eraseToAnyPublisher()
    }

    func syncWithServer() {
        logger.debug("sync with server")
        fetchCalendars()
        fetchColorDefinitions()
    }
}
