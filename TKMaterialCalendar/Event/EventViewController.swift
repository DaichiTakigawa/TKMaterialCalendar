//
//  EventViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class EventViewController: UIViewController {

    private let initialDate: String

    init(initialDate: String) {
        self.initialDate = initialDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
