//
//  CalendarViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit

class CalendarViewController: UIViewController {

    private let rootNavigator: RootNavigator
    private var nowYearMonth: String

    private lazy var currentVC: MonthViewController = {
        MonthViewController(yearMonth: nowYearMonth)
    }()

    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.setViewControllers([currentVC], direction: .forward, animated: false)
        vc.delegate = self
        vc.dataSource = self
        return vc
    }()

    init(rootNavigator: RootNavigator) {
        self.rootNavigator = rootNavigator
        self.nowYearMonth = DateUtils.today.toFormattedString(format: "yyyy/MM")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLayout()
    }

    private func setupNavigationBar() {
        title = nowYearMonth

        let menuImage = R.image.iconMenu()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(menuItemTapped))

        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let ellipsisImage = UIImage(systemName: "ellipsis", withConfiguration: config)
        let ellipsisButton = UIButton()
        ellipsisButton.setImage(ellipsisImage, for: .normal)
        let refreshAction = UIAction(title: R.string.localizable.refresh()) { [weak self] _ in
            if let vc = self?.currentVC {
                vc.refresh()
            }
        }
        let settingsAction = UIAction(title: R.string.localizable.settings()) { _ in
        }
        ellipsisButton.menu = UIMenu(title: "", children: [refreshAction, settingsAction])
        ellipsisButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        ellipsisButton.showsMenuAsPrimaryAction = true
        let optionItem = UIBarButtonItem(customView: ellipsisButton)

        let todayImage = R.image.iconToday()
        let todayButton = UIButton()
        todayButton.setImage(todayImage, for: .normal)
        todayButton.addTarget(self, action: #selector(onTodayTapped), for: .touchUpInside)
        todayButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let todayItem = UIBarButtonItem(customView: todayButton)
        navigationItem.rightBarButtonItems = [optionItem, todayItem]
    }

    private func setupLayout() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        pageViewController.didMove(toParent: self)

        view.backgroundColor = R.color.colorBackground()
    }

    @objc private func onTodayTapped() {
        let vc = pageViewController.viewControllers?.first as! MonthViewController
        let yearMonth = vc.yearMonth
        let offset = DateUtils.getMonthOffset(from: yearMonth, to: nowYearMonth)
        if offset > 0 {
            pageViewController.setViewControllers([MonthViewController(yearMonth: nowYearMonth)],
                                                  direction: .reverse,
                                                  animated: true)
        } else if offset < 0 {
            pageViewController.setViewControllers([MonthViewController(yearMonth: nowYearMonth)],
                                                  direction: .forward,
                                                  animated: true)
        }
        title = nowYearMonth
    }

    @objc private func menuItemTapped() {
        rootNavigator.setDrawerState(isOpen: true)
    }
}

extension CalendarViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentVC = (pageViewController.viewControllers?.first as! MonthViewController)
            title = currentVC.yearMonth
        }
    }

}

extension CalendarViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let yearMonth = (viewController as! MonthViewController).yearMonth
        let prevYearMonth = yearMonth.toPrevMonth()
        return MonthViewController(yearMonth: prevYearMonth)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let yearMonth = (viewController as! MonthViewController).yearMonth
        let nextYearMonth = yearMonth.toNextMonth()
        return MonthViewController(yearMonth: nextYearMonth)
    }
}
