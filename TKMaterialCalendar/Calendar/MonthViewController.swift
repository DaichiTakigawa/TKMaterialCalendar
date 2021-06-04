//
//  MonthViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/03.
//

import UIKit
import Combine
import Swinject
import SwinjectAutoregistration
import MaterialComponents.MaterialProgressView

class MonthViewController: UIViewController {

    private let viewModel = DI.shared ~> MonthViewViewModel.self
    private var cancellables = Set<AnyCancellable>()
    private var events: [Event] = []

    private lazy var progressView: MDCProgressView = {
        let view = MDCProgressView()
        view.progressTintColor = MaterialScheme.shared.colorScheme.secondaryColor
        view.trackTintColor = MaterialScheme.shared.colorScheme.secondaryColor.withAlphaComponent(0.24)
        view.mode = .indeterminate
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var monthCalendarView: MonthCalendarView = {
        let view = MonthCalendarView(yearMonth: yearMonth)
        view.dataSource = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // yyyy/MM
    let yearMonth: String

    init(yearMonth: String) {
        self.yearMonth = yearMonth
        super.init(nibName: nil, bundle: nil)
        viewModel.setup(targetMonth: yearMonth)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupObserver()
        progressView.startAnimating()
    }

    private func setupLayout() {
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        view.addSubview(monthCalendarView)
        NSLayoutConstraint.activate([
            monthCalendarView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 2),
            monthCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            monthCalendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.backgroundColor = R.color.colorBackground()
    }

    private func setupObserver() {
        viewModel.$events.sink { [weak self] events in
            self?.events = events
            self?.monthCalendarView.refresh()
            self?.progressView.stopAnimating()
            self?.progressView.isHidden = true
        }
        .store(in: &cancellables)
    }

    func refresh() {
        viewModel.fetchEvents(targetMonth: yearMonth)
        progressView.startAnimating()
        progressView.isHidden = false
    }

}

extension MonthViewController: MonthCalendarViewDataSource {
    func monthCalendarViewDataSource() -> [Event] {
        events
    }
}

extension MonthViewController: MonthCalendarViewDelegate {
    func monthCalendarView(selected date: String) {
        let vc = EventViewController(initialDate: date)
        navigationController?.pushViewController(vc, animated: false)
    }
}
