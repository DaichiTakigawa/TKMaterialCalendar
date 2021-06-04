//
//  MonthEventViewState.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class MonthEventViewState {

    var startDayOfWeek: WeekDay
    var eventRectList: [MonthEventView.EventRect] = []
    var extraTextList: [MonthEventView.ExtraText] = []

    init(startDayOfWeek: WeekDay) {
        self.startDayOfWeek = startDayOfWeek
    }

    private func createInternalEvents(
        _ eventList: [Event],
        _ monthStartDate: Date,
        _ monthEndDate: Date
    ) -> [Event] {
        eventList.flatMap { event -> [Event] in
            var startDate = max(event.startDate, monthStartDate)
            let endDate = min(event.endDate, monthEndDate)
            if startDate > endDate {
                return []
            }
            var date = startDate
            var nextId = 0
            var list: [Event] = []
            while DateUtils.dateDiff(from: date, to: endDate) > 0 {
                if isStartDayOfWeek(date.toNextDate()) {
                    list.append(
                        Event(id: "\(event.id)#\(nextId)",
                              label: event.label,
                              color: event.color,
                              startDate: startDate,
                              endDate: date)
                    )
                    nextId += 1
                    startDate = date.toNextDate()
                }
                date = date.toNextDate()
            }
            list.append(
                Event(id: "\(event.id)#\(nextId)",
                      label: event.label,
                      color: event.color,
                      startDate: startDate,
                      endDate: endDate)
            )
            return list
        }.sorted {
            if DateUtils.dateDiff(from: $0.startDate, to: $1.startDate) != 0 {
                return $0.startDate < $1.startDate
            } else {
                return $0.endDate > $1.endDate
            }
        }
    }

    private func isStartDayOfWeek(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: date)
        return component == startDayOfWeek.rawValue
    }

    func update(eventList: [Event], eventRowSize: Int, monthStartDate: Date, monthEndDate: Date) {
        // clear previous data
        eventRectList = []
        extraTextList = []

        if eventRowSize == 0 {
            return
        }

        let events = createInternalEvents(eventList, monthStartDate, monthEndDate)
        var eventTable = (0..<(6 * 7)).map { _ -> [Event?] in
            [Event?](repeating: nil, count: eventRowSize)
        }
        var extraEventCount = [Int](repeating: 0, count: 6 * 7)

        events.forEach { event in
            let firstIndex = DateUtils.dateDiff(from: monthStartDate, to: event.startDate)
            let lastIndex = firstIndex + DateUtils.dateDiff(from: event.startDate, to: event.endDate) + 1
            let pos = eventTable[firstIndex].firstIndex {
                $0 == nil
            }
            for i in firstIndex..<lastIndex {
                if let pos = pos {
                    eventTable[i][pos] = event
                } else {
                    extraEventCount[i] += 1
                }
            }
        }

        for (i, eventCount) in extraEventCount.enumerated() where eventCount > 0 {
            if let event = eventTable[i][eventRowSize - 1] {
                var i2 = i
                while i2 < (6 * 7) && event.id == eventTable[i2][eventRowSize - 1]?.id {
                    eventTable[i2][eventRowSize - 1] = nil
                    extraEventCount[i2] += 1
                    i2 += 1
                }

            }
        }

        for (i, eventsOfDay) in eventTable.enumerated() {
            let x = i % 7
            let y = (i - x) / 7
            for (row, event) in eventsOfDay.enumerated() {
                if let event = event {
                    var stopX = x
                    var i2 = i
                    while i2 < (6 * 7) && event.id == eventTable[i2][row]?.id {
                        eventTable[i2][row] = nil
                        stopX += 1
                        i2 += 1
                    }
                    eventRectList.append(
                        MonthEventView.EventRect(startX: x,
                                                 stopX: stopX,
                                                 y: y,
                                                 rowPos: row,
                                                 label: event.label,
                                                 color: event.color)
                    )
                }
            }
        }

        for (i, eventCount) in extraEventCount.enumerated() where eventCount > 0 {
            let x = i % 7
            let y = (i - x) / 7
            extraTextList.append(
                MonthEventView.ExtraText(x: x, y: y, text: "+\(eventCount)")
            )
        }
    }

}
