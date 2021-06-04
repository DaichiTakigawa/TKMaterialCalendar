//
//  MonthEventView.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class MonthEventView: UIView {

    class EventRect {
        let startX: Int
        let stopX: Int
        let y: Int
        let rowPos: Int
        let label: String
        let color: UIColor

        init(startX: Int, stopX: Int, y: Int, rowPos: Int, label: String, color: UIColor) {
            self.startX = startX
            self.stopX = stopX
            self.y = y
            self.rowPos = rowPos
            self.label = label
            self.color = color
        }
    }

    class ExtraText {
        let x: Int
        let y: Int
        let text: String

        init(x: Int, y: Int, text: String) {
            self.x = x
            self.y = y
            self.text = text
        }
    }

    private let ALPHA: CGFloat = 0.8

    private var dayWidth: CGFloat = 0
    private var dayHeight: CGFloat = 0
    private let weekDaysHeight: CGFloat
    private let weekDaysLetterSize: CGFloat
    private let dateLetterSize: CGFloat
    private let dateTextHeight: CGFloat
    private let eventLetterSize: CGFloat
    private let eventHeight: CGFloat
    private let extraLetterSize: CGFloat
    private let extraTextHeight: CGFloat
    private let baseColor: UIColor
    private let gridColor: UIColor
    private let todayColor: UIColor
    private let weakTextColor: UIColor
    private let strongTextColor: UIColor
    private let weekDaysTextColor: UIColor
    private let eventTextColor: UIColor
    private let extraTextColor: UIColor
    private let strokeWidth: CGFloat
    private var eventRowSize = 0
    private var todayString = ""

    var yearMonth: String
    var startDayOfWeek: WeekDay = .sunday
    var eventList: [Event] = []

    private lazy var state: MonthEventViewState = {
        MonthEventViewState(startDayOfWeek: startDayOfWeek)
    }()

    init(yearMonth: String) {
        self.yearMonth = yearMonth
        weekDaysHeight = 20
        dateTextHeight = 16
        eventHeight = 16
        extraTextHeight = 16
        weekDaysLetterSize = 14
        dateLetterSize = 10
        eventLetterSize = 10
        extraLetterSize = 10

        baseColor = R.color.colorDivider.uiColor
        gridColor = baseColor
        strokeWidth = 1

        todayColor = R.color.colorSecondary.uiColor
        weakTextColor = baseColor
        strongTextColor = baseColor.withAlphaComponent(ALPHA)
        weekDaysTextColor = baseColor.withAlphaComponent(ALPHA)
        eventTextColor = .black
        extraTextColor = baseColor.withAlphaComponent(ALPHA)

        super.init(frame: .zero)

        todayString = DateUtils.today.toFormattedString(format: "yyyy/MM/dd")
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        measureDaySize()
        drawGrid()
        drawDayOfWeekText()
        drawDateText()
        drawEvent()
    }

    private func measureDaySize() {
        dayWidth = bounds.width / 7
        dayHeight = (bounds.height - weekDaysHeight) / 6
        eventRowSize = Int((dayHeight - dateTextHeight) / eventHeight)
    }

    private func drawGrid() {
        for i in 0..<7 {
            let posX = CGFloat(i) * dayWidth
            let startY = weekDaysHeight * 0.7
            let stopY = bounds.height
            let path = UIBezierPath()
            path.move(to: CGPoint(x: posX, y: startY))
            path.addLine(to: CGPoint(x: posX, y: stopY))
            gridColor.set()
            path.lineWidth = strokeWidth
            path.stroke()
        }

        for i in 0..<6 {
            let posY = CGFloat(i) * dayHeight + weekDaysHeight
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: posY))
            path.addLine(to: CGPoint(x: bounds.width, y: posY))
            gridColor.set()
            path.lineWidth = strokeWidth
            path.stroke()
        }
    }

    private func drawDayOfWeekText() {
        let dayOfWeeks = (0..<7).map { it -> String in
            var rawValue = startDayOfWeek.rawValue + it
            if rawValue > 7 {
                rawValue -= 7
            }
            return WeekDay(rawValue: rawValue)!.getLocalizedString()
        }
        for (i, str) in dayOfWeeks.enumerated() {
            let posX = CGFloat(i) * dayWidth
            drawText(label: str,
                     in: CGRect(x: posX, y: 2, width: dayWidth, height: weekDaysHeight - 2),
                     fontSize: weekDaysLetterSize,
                     textColor: weekDaysTextColor)
        }
    }

    private func drawDateText() {
        let dateList = DateUtils.getDateListOfMonth(yearMonth: yearMonth, startDayOfWeek: startDayOfWeek)
        var index = 0
        for y in 0..<6 {
            for x in 0..<7 {
                let date = dateList[index]
                let posX = CGFloat(x) * dayWidth
                let posY = weekDaysHeight + (CGFloat(y) * dayHeight)
                let textColor = (date.toYearMonth() == yearMonth) ? strongTextColor : weakTextColor
                let isToday = date == todayString
                let label = String(Int(String(date.split(separator: "/").last!))!)
                if isToday {
                    let centerX = posX + dayWidth / 2
                    let centerY = posY + dateTextHeight / 2 + dateLetterSize / 4
                    let circle = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                              radius: dateTextHeight * 0.45,
                                              startAngle: 0,
                                              endAngle: CGFloat(Double.pi) * 2,
                                              clockwise: true)
                    todayColor.setFill()
                    circle.fill()
                }
                drawText(label: label, in: CGRect(x: posX, y: posY + dateLetterSize / 2,
                                                  width: dayWidth, height: dateTextHeight),
                         fontSize: dateLetterSize,
                         textColor: textColor)
                index += 1
            }
        }
    }

    private func drawEvent() {
        // resolve position
        if eventRowSize == 0 {
            return
        }
        let dateList = DateUtils.getDateListOfMonth(yearMonth: yearMonth, startDayOfWeek: startDayOfWeek)
        let monthStartDate = dateList.first!.toDate(format: "yyyy/MM/dd")
        let monthEndDate = dateList.last!.toDate(format: "yyyy/MM/dd")
        state.update(eventList: eventList,
                     eventRowSize: eventRowSize,
                     monthStartDate: monthStartDate,
                     monthEndDate: monthEndDate)

        // draw events
        drawEventRect(state.eventRectList)

        // draw extra texts
        drawExtraText(state.extraTextList)
    }

    private func drawEventRect(_ events: [EventRect]) {
        for event in events {
            let padding: CGFloat = 2
            let x = CGFloat(event.startX) * dayWidth
            let y = weekDaysHeight + CGFloat(event.y) * dayHeight + dateTextHeight + CGFloat(event.rowPos) * eventHeight
            let width = dayWidth * CGFloat(event.stopX - event.startX) - padding
            let height = eventHeight - padding
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 1)
            event.color.setFill()
            path.fill()
            drawText(label: event.label,
                     in: rect,
                     fontSize: eventLetterSize,
                     textColor: eventTextColor,
                     alignment: .left)
        }
    }

    private func drawExtraText(_ extraTexts: [ExtraText]) {
        for text in extraTexts {
            let padding: CGFloat = 2
            let x = CGFloat(text.x) * dayWidth
            let y = weekDaysHeight + CGFloat(text.y + 1) * dayHeight - extraTextHeight
            let width = dayWidth - padding
            let height = extraTextHeight - padding
            drawText(label: text.text,
                     in: CGRect(x: x, y: y, width: width, height: height),
                     fontSize: extraLetterSize, textColor: extraTextColor, alignment: .right)
        }
    }

    private func drawText(label: String,
                          `in`: CGRect,
                          fontSize: CGFloat,
                          textColor: UIColor,
                          alignment: NSTextAlignment = .center) {
        let font = UIFont.systemFont(ofSize: fontSize)
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        let attribute = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        (label as NSString).draw(in: `in`, withAttributes: attribute)
    }
}

private extension String {
    func toYearMonth() -> String {
        let index = self.lastIndex(of: "/")!
        let newString = String(self[self.startIndex..<index])
        return newString
    }
}
