//
//  Rswift+Extensions.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import Rswift

extension ColorResource {
    var uiColor: UIColor {
        UIColor(named: name)!
    }

    var cgColor: CGColor {
        uiColor.cgColor
    }
}

extension ImageResource {
    var uiImage: UIImage {
        UIImage(named: name)!
    }
}
