//
//  ItemViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import RealmSwift
import UIKit

class ItemViewController: UIViewController {
    var todoItems: Results<Item>?

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .label
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func addButonPressed() {
    }

}
