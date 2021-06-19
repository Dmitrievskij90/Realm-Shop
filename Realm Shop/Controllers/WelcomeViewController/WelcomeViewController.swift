//
//  ViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var getStartedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        getStartedButton.layer.cornerRadius = 65
    }

    @IBAction private func getStartedButtonPressed(_ sender: UIButton) {
    }
}
