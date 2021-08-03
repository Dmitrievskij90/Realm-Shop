//
//  WelcomeScreenPresenter.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 28.07.2021.
//

import UIKit

class WelcomeScreenPresenter {
    private let view: WelcomeViewController

    init(view: WelcomeViewController) {
        self.view = view
    }

    func viewDidLoad(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.backgroundColor = .init(hex: 0xF4D085)
    }

    func viewWillAppear(_ navigationController: UINavigationController?) {
        navigationController?.navigationBar.isHidden = true
    }

    func getStartedButtonPressed(_ navigationController: UINavigationController?) {
        let viewController = CategoryViewController.instantiate()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }
}
