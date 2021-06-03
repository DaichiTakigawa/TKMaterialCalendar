//
//  MonthViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class MonthViewController: UIViewController {

    // yyyy/MM
    let yearMonth: String

    init(yearMonth: String) {
        self.yearMonth = yearMonth
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func refresh() {

    }

}
