//
//  MainViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit

class MainViewController: UIViewController {

    private let rootNavigator: RootNavigator

    init(rootNavigator: RootNavigator) {
        self.rootNavigator = rootNavigator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
