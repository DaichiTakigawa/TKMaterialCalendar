//
//  DrawerContentViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit
import Combine
import Swinject
import SwinjectAutoregistration

class DrawerContentViewController: UIViewController {

    private static let calendarCellId = "CalendarCell"
    private let rootNavigator: RootNavigator
    private let viewModel = DI.shared ~> DrawerContentViewModel.self
    private var calendars: [CalendarEntity] = []
    private var cancellables: Set<AnyCancellable> = []

    private var settingIconImage: UIImage {
        R.image.iconSettings.uiImage
    }

    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(settingIconImage, for: .normal)
        button.addTarget(self, action: #selector(settingIconTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var profileImage: UIImage {
        UIImage(systemName: "person.crop.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 42))!
            .withTintColor(MaterialScheme.shared.colorScheme.onSurfaceColor, renderingMode: .alwaysOriginal)
    }

    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()

    private lazy var userIdLabel: UILabel = {
        let userIdLabel = UILabel()
        userIdLabel.text = viewModel.userId
        userIdLabel.font = .systemFont(ofSize: 14)
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        return userIdLabel
    }()

    private lazy var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = UIColor.separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()

    private lazy var projectHeaderLabel: UILabel = {
        let uiLabel = UILabel()
        uiLabel.text = "Calendars"
        uiLabel.font = .systemFont(ofSize: 20)
        uiLabel.translatesAutoresizingMaskIntoConstraints = false
        return uiLabel
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(DrawerCalendarTableViewCell.self, forCellReuseIdentifier: Self.calendarCellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(rootNavigator: RootNavigator) {
        self.rootNavigator = rootNavigator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupObservers()

        viewModel.searchCalendars()
    }

    private func setupObservers() {
        viewModel.$calendars.sink { [unowned self] calendars in
            self.calendars = calendars
            tableView.reloadData()
        }
        .store(in: &cancellables)
    }

    private func setupLayout() {
        let safeAreaGuide = view.safeAreaLayoutGuide

        // vertical stack view
        let vStackView = UIStackView()
        vStackView.axis = .vertical
        vStackView.alignment = .fill

        view.addSubview(vStackView)

        vStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 16),
            vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // view1
        let view1 = UIView()
        vStackView.addArrangedSubview(view1)

        // setting icon image view
        view1.addSubview(settingButton)
        NSLayoutConstraint.activate([
            settingButton.topAnchor.constraint(equalTo: view1.topAnchor, constant: 16),
            settingButton.trailingAnchor.constraint(equalTo: view1.trailingAnchor),
            view1.heightAnchor.constraint(equalTo: settingButton.heightAnchor, constant: 32)
        ])

        // view2
        let view2 = UIView()
        vStackView.addArrangedSubview(view2)

        // profile icon image view
        view2.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view2.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            view2.heightAnchor.constraint(equalTo: profileImageView.heightAnchor, constant: 32)
        ])

        // user id label
        view2.addSubview(userIdLabel)
        NSLayoutConstraint.activate([
            userIdLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            userIdLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            userIdLabel.trailingAnchor.constraint(equalTo: view2.trailingAnchor)
        ])

        // divider
        view.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])

        // project header label
        view.addSubview(projectHeaderLabel)
        NSLayoutConstraint.activate([
            projectHeaderLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            projectHeaderLabel.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 16),
            projectHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // table view
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: projectHeaderLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor)
        ])

        view.backgroundColor = R.color.colorDrawer()
    }

    @objc private func settingIconTapped(_ sender: UITapGestureRecognizer) {
        let vc = UINavigationController(rootViewController: SettingViewController(rootNavigator: rootNavigator))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}

extension DrawerContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        calendars.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.calendarCellId) as! DrawerCalendarTableViewCell
        let calendar = calendars[indexPath.row]
        cell.bind(calendar: calendar)
        return cell
    }
}

extension DrawerContentViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#if DEBUG
import SwiftUI

struct DrawerContentViewWrapper: UIViewControllerRepresentable {

    init() {
        let c = Container(parent: DI.shared)
        c.register(DrawerContentViewModel.self) { _ in
            let viewModelMock = DrawerContentViewModelMock()
            viewModelMock.fetchCalendarListHandler = {
                let c1 = CalendarEntity()
                c1.summary = "Calendar 1"
                let c2 = CalendarEntity()
                c2.summary = "Calendar 2"
                viewModelMock.calendars = [c1, c2]
            }
            viewModelMock.userId = "hogehoge@example.com"
            return viewModelMock
        }
        DI.replaceShared(container: c)
    }

    func makeUIViewController(context: Context) -> DrawerContentViewController {
        DrawerContentViewController(rootNavigator: RootNavigatorMock())
    }

    func updateUIViewController(_ uiViewController: DrawerContentViewController, context: Context) {

    }
}

struct DrawerContentViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        DrawerContentViewWrapper()
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
#endif
