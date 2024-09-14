//
//  Coordinator.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/18/24.
//
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = HomeViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func presentPokemon(viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
//    func showPokemonDetails(for pokemon: Pokemon) {
////        let viewModel = PokemonDetailViewModel(pokemon: pokemon)
////        let detailViewController = PokemonDetailViewController(viewModel: viewModel)
//        detailViewController.coordinator = self
//        navigationController?.pushViewController(detailViewController, animated: true)
//    }
//
//    func showSecondaryDetail(for detail: SecondaryDetail) {
////        let viewModel = SecondaryDetailViewModel(detail: detail)
////        let secondaryDetailViewController = SecondaryDetailViewController(viewModel: viewModel)
//        navigationController?.pushViewController(secondaryDetailViewController, animated: true)
//    }
}
