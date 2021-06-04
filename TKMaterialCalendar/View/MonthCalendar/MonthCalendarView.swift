//
//  MonthCalendarView.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit
import MaterialComponents.MaterialRipple

class MonthCalendarView: UIView {

    private var dayWidth: CGFloat = 0
    private var dayHeight: CGFloat = 0
    private var weekDaysHeight: CGFloat = 0
    private var rippleTouchControllers: [MDCRippleTouchController] = []
    private var selectableItems: [UIView] = []
    private var dates: [String] = []

    let yearMonth: String
    var startDayOfWeek: WeekDay = .sunday
    var dataSource: MonthCalendarViewDataSource?
    weak var delegate: MonthCalendarViewDelegate?

    private lazy var monthEventView: MonthEventView = {
        let monthEventView = MonthEventView(yearMonth: yearMonth)
        monthEventView.translatesAutoresizingMaskIntoConstraints = false
        return monthEventView
    }()

    init(yearMonth: String) {
        self.yearMonth = yearMonth
        weekDaysHeight = 20

        super.init(frame: .zero)

        selectableItems = (0..<(6 * 7)).map { [unowned self] i in
            let view = UIView()
            let rippleTouchController = MaterialScheme.shared.defaultRippleTouchController()
            rippleTouchController.addRipple(to: view)
            rippleTouchControllers.append(rippleTouchController)
            view.tag = i
            addSubview(view)
            return view
        }

        addSubview(monthEventView)
        NSLayoutConstraint.activate([
            monthEventView.topAnchor.constraint(equalTo: topAnchor),
            monthEventView.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthEventView.bottomAnchor.constraint(equalTo: bottomAnchor),
            monthEventView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let widthSize = bounds.width
        let heightSize = frame.height

        dayWidth = widthSize / 7
        dayHeight = (heightSize - weekDaysHeight) / 6

        for y in 0..<6 {
            for x in 0..<7 {
                let posX = CGFloat(x) * dayWidth
                let posY = CGFloat(y) * dayHeight + weekDaysHeight
                selectableItems[y * 7 + x].frame = CGRect(x: posX, y: posY, width: dayWidth, height: dayHeight)
            }
        }

        dates = DateUtils.getDateListOfMonth(yearMonth: yearMonth, startDayOfWeek: startDayOfWeek)
        for y in 0..<6 {
            for x in 0..<7 {
                let index = y * 7 + x
                let selectableItem = selectableItems[index]
                selectableItem.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectableItemTapped(_:)))
                selectableItem.addGestureRecognizer(tapGesture)
            }
        }
    }

    func refresh() {
        guard let eventList = dataSource?.monthCalendarViewDataSource() else {
            return
        }
        monthEventView.eventList = eventList
        monthEventView.setNeedsDisplay()
    }

    @objc private func selectableItemTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else {
            return
        }
        let date = dates[index]
        delegate?.monthCalendarView(selected: date)
    }

}

protocol MonthCalendarViewDataSource {
    func monthCalendarViewDataSource() -> [Event]
}

protocol MonthCalendarViewDelegate: AnyObject {
    func monthCalendarView(selected date: String)
}
