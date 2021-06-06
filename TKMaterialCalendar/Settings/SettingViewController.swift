//
//  SettingViewController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/06.
//

import UIKit
import GoogleSignIn

class SettingViewController: UIViewController {

    private let rootNavigator: RootNavigator

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
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

        setupNavigationBar()
        setupLayout()
    }

    private func setupNavigationBar() {
        title = R.string.localizable.settings()

        let closeImage = UIImage(systemName: "xmark")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(closeItemTapped))

    }

    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.backgroundColor = R.color.colorBackground()
    }

    private func onSignOutRowTapped() {
        let dialog = UIAlertController(title: "Sign Out", message: "Are you sure to sign out?", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        dialog.addAction(UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            let signIn = GIDSignIn.sharedInstance()
            signIn?.signOut()
            self?.dismiss(animated: false) {
                self?.rootNavigator.navigateTo(destination: .splash)
            }
        })
        present(dialog, animated: true)
    }

    @objc private func closeItemTapped() {
        self.dismiss(animated: true)
    }

}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Sign Out"
        cell.backgroundColor = .clear
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSignOutRowTapped()
    }
}
