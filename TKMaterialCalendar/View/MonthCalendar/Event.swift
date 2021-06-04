//
//  Event.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class Event {
    let id: String
    let label: String
    let color: UIColor
    let startDate: Date
    let endDate: Date

    init(id: String, label: String, color: UIColor, startDate: Date, endDate: Date) {
        self.id = id
        self.label = label
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
    }

}
