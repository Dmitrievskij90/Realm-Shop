//
//  ViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    lazy var presenter = WelcomeScreenPresenter(view: self)
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad(getStartedButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear(navigationController)
    }

    @IBAction private func getStartedButtonPressed(_ sender: UIButton) {
        presenter.getStartedButtonPressed(navigationController)
    }
}
