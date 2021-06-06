//
//  CalendarColor.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import Foundation
import UIKit
import RealmSwift
import GoogleAPIClientForREST

class ColorDefinition: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var foreground: String?
    @objc dynamic var background: String?

    override static func primaryKey() -> String? {
        "id"
    }

    static func deleteAll(`in` realm: Realm) throws {
        let allObjects = realm.objects(self)
        try realm.write {
            realm.delete(allObjects)
        }
    }

    static func getAll(`in` realm: Realm) -> [ColorDefinition] {
        Array(realm.objects(self))
    }

    func populate(id: String, color: GTLRCalendar_ColorDefinition) {
        self.id = id
        foreground = color.foreground
        background = color.background
    }

    func getBackgroundUIColor() -> UIColor? {
        guard let background = self.background else {
            return nil
        }
        return UIColor(hex: background)
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
