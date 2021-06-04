//
//  Calendar.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import RealmSwift
import GoogleAPIClientForREST

class CalendarEntity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var summary: String?

    override static func primaryKey() -> String? {
        "id"
    }

    static func deleteAll(`in` realm: Realm) throws {
        let allObjects = realm.objects(self)
        try realm.write {
            realm.delete(allObjects)
        }
    }

    static func getAll(`in` realm: Realm) -> [CalendarEntity] {
        Array(realm.objects(self))
    }

    func populate(from calendar: GTLRCalendar_CalendarListEntry) {
        id = calendar.identifier!
        summary = calendar.summary
    }
}
