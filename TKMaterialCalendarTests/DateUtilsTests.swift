//
//  DateUtilsTests.swift
//  TKMaterialCalendarTests
//
//  Created by takigawa on 2021/06/05.
//

import XCTest
import Nimble
@testable import TKMaterialCalendar

class DateUtilsTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    func test_getDateListOfMonth関数が正しいリストを返す() {
        // assign
        let yearMonth = "2021/04"

        // act
        let dates = DateUtils.getDateListOfMonth(yearMonth: yearMonth, startDayOfWeek: .sunday)

        // assert
        expect(dates.count) == 42
        let firstDate = dates.first!.toDateOrNil(format: "yyyy/MM/dd")!
        let firstDateComponents = calendar.dateComponents([.year, .month, .day], from: firstDate)
        expect(firstDateComponents.year) == 2021
        expect(firstDateComponents.month) == 3
        expect(firstDateComponents.day) == 28
        let lastDate = dates.last!.toDateOrNil(format: "yyyy/MM/dd")!
        let lastDateComponents = calendar.dateComponents([.year, .month, .day], from: lastDate)
        expect(lastDateComponents.year) == 2021
        expect(lastDateComponents.month) == 5
        expect(lastDateComponents.day) == 8
    }

    func test_Stringの拡張関数toDateが年と月のみを指定した場合に正しいDateを返す() {
        // assign
        let yearMonth = "2021/04"

        // act
        let date = yearMonth.toDateOrNil(format: "yyyy/MM")

        // assert
        expect(date).notTo(beNil())
        if let date = date {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            expect(components.year) == 2021
            expect(components.month) == 4
            expect(components.day) == 1
        }
    }

    func test_dateDiff関数の2つの引数に同じ日時を渡すと0を返す() {
        // assign
        let date = Date()

        // act
        let diff = DateUtils.dateDiff(from: date, to: date)

        // assert
        expect(diff) == 0
    }

    func test_dateDiff関数が返す日数の差は時間的なものではなく日付の差() {
        // assign
        let date1 = "2022/06/13 23:59:59".toDate()
        let date2 = "2022/06/14 00:00:00".toDate()

        // act
        let diff = DateUtils.dateDiff(from: date1, to: date2)

        // assert
        expect(diff) == 1
    }

    func test_dateDiffは1日異なるDateが渡された時に1を返す() {
        // assign
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let fromDate = Date()
        let toDate = calendar.date(byAdding: oneDayComponents, to: fromDate)!

        // act
        let diff = DateUtils.dateDiff(from: fromDate, to: toDate)

        // assert
        expect(diff) == 1
    }

    func test_dateDiff関数の引数の日数の差が3日遅れの場合はマイナス3を返す() {
        // assign
        var oneDayComponents = DateComponents()
        oneDayComponents.day = -3
        let fromDate = Date()
        let toDate = calendar.date(byAdding: oneDayComponents, to: fromDate)!

        // act
        let diff = DateUtils.dateDiff(from: fromDate, to: toDate)

        // assert
        expect(diff) == -3
    }

    func test_Stringの拡張関数toNextMonthが正しい年月を返す() {
        // assign
        let yearMonth = "1998/10"

        // act
        let nextMonth = yearMonth.toNextMonth()

        // assert
        expect(nextMonth) == "1998/11"
    }

    func test_Stringの拡張関数toNextMonthが年を跨いでも正しい年月を返す() {
        // assign
        let yearMonth = "1998/12"

        // act
        let nextMonth = yearMonth.toNextMonth()

        // assert
        expect(nextMonth) == "1999/01"
    }

    func test_Stringの拡張関数toPrevMonthが正しい年月を返す() {
        // assign
        let yearMonth = "1998/10"

        // act
        let nextMonth = yearMonth.toPrevMonth()

        // assert
        expect(nextMonth) == "1998/09"
    }

    func test_Stringの拡張関数toPrevMonthが年を跨いでも正しい年月を返す() {
        // assign
        let yearMonth = "1998/01"

        // act
        let nextMonth = yearMonth.toPrevMonth()

        // assert
        expect(nextMonth) == "1997/12"
    }

    func test_Stringの拡張関数toDateが対応するDateを返す() {
        // assign
        let dateStr = "2021/06/05"

        // act
        let date = dateStr.toDate(format: "yyyy/MM/dd")

        // assert
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        expect(components.year) == 2021
        expect(components.month) == 6
        expect(components.day) == 5
        expect(components.hour) == 0
        expect(components.minute) == 0
        expect(components.second) == 0
    }

}
