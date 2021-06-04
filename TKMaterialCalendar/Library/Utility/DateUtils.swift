//
//  DateUtils.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation

class DateUtils {

    private static let SECOND_A_DAY = 60 * 60 * 24
    static let today = Calendar(identifier: .gregorian).startOfDay(for: Date())

    private static var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }

    private init() {
    }

    private static func getDate(date: Date, offset: Int) -> Date {
        let offsetDate = calendar.date(byAdding: .day, value: offset, to: date)!
        return offsetDate
    }

    private static func getStartDateOf(yearMonth: String) -> Date {
        let date = yearMonth.toDate(format: "yyyy/MM")
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    static func getMonthOffset(from: String, to: String) -> Int {
        let fromDate = getStartDateOf(yearMonth: from)
        let toDate = getStartDateOf(yearMonth: to)

        let difference = calendar.dateComponents([.month], from: fromDate, to: toDate)
        return difference.month ?? 0
    }

    static func getDateListOfMonth(yearMonth: String, startDayOfWeek: WeekDay) -> [String] {
        guard let startDayOfMonth = yearMonth.toDateOrNil(format: "yyyy/MM") else {
            return []
        }

        let firstDayOfWeek = calendar.component(.weekday, from: startDayOfMonth)

        var firstDayOfWeekIndex = 0
        for i in 0..<7 {
            var dayOfWeek = startDayOfWeek.rawValue + i
            if dayOfWeek > 7 {
                dayOfWeek -= 7
            }
            if dayOfWeek == firstDayOfWeek {
                firstDayOfWeekIndex = i
                break
            }
        }

        let startDate = getDate(date: startDayOfMonth, offset: -firstDayOfWeekIndex)
        return (0..<(6 * 7)).map { i in
            let date = getDate(date: startDate, offset: i)
            return date.toFormattedString(format: "yyyy/MM/dd")
        }
    }

    static func dateDiff(from fromDate: Date, to toDate: Date) -> Int {
        let date1 = fromDate.toFormattedString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")
        let date2 = toDate.toFormattedString(format: "yyyy/MM/dd").toDate(format: "yyyy/MM/dd")
        let delta = date2.timeIntervalSince(date1)
        return Int(delta / Double(SECOND_A_DAY))
    }

}

enum WeekDay: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    func getLocalizedString() -> String {
        switch self {
        case .sunday:
            return R.string.localizable.sun()
        case .monday:
            return R.string.localizable.mon()
        case .tuesday:
            return R.string.localizable.tue()
        case .wednesday:
            return R.string.localizable.wed()
        case .thursday:
            return R.string.localizable.thu()
        case .friday:
            return R.string.localizable.fri()
        case .saturday:
            return R.string.localizable.sat()
        }
    }
}

extension Date {
    func toFormattedString(format: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    func toNextDate() -> Date {
        let comp = DateComponents(day: 1)
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: comp, to: self)!
    }
}

extension String {
    func toDateOrNil(format: String = "yyyy/MM/dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }

    func toDate(format: String = "yyyy/MM/dd HH:mm:ss") -> Date {
        toDateOrNil(format: format)!
    }

    func toNextMonth() -> String {
        let date = toDate(format: "yyyy/MM")
        let components = DateComponents(month: 1)
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: components, to: date)!.toFormattedString(format: "yyyy/MM")
    }

    func toPrevMonth() -> String {
        let date = toDate(format: "yyyy/MM")
        let components = DateComponents(month: -1)
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: components, to: date)!.toFormattedString(format: "yyyy/MM")
    }
}
