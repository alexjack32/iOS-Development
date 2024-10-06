//
//  HomeViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/28/24.
//

import DD4Y_UIKit
import UIKit

struct HomeViewModel {
    let text: String
    let viewController: UIViewController
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.row].text
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedViewController = items[indexPath.row].viewController
        coordinator?.presentNextViewController(viewController: selectedViewController)
    }
}

class HomeViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    
    let tableView: UITableView
    let displayView = BaseView()
    let items: [HomeViewModel] = [
        HomeViewModel(text: "Pokemon", viewController: PokemonViewController()),
        HomeViewModel(text: "Pexels", viewController: PexelsViewController()),
        HomeViewModel(text: "Pexels Videos", viewController: PexelsVideoViewController()),
        HomeViewModel(text: "Diffable Data Source", viewController: DiffableDataSourceViewController()),
        HomeViewModel(text: "Content Insets", viewController: ContentInsetsViewController())
    ]
    
    init() {
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
        title = "MVVM+C Practice Sections"
        view.backgroundColor = .systemBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [weak self] in
            if let self,
               let navigationController = self.navigationController {
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.systemYellow
                ]
            }
        }
    }
    
    
}
