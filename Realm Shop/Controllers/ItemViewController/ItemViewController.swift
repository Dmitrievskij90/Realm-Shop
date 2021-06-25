//
//  ItemViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import RealmSwift
import UIKit

class ItemViewController: UIViewController {
    private var items: Results<Item>?
    private let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .label

        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.register(ItemTableViewCell.nib(), forCellReuseIdentifier: ItemTableViewCell.identifier)
        title = selectedCategory?.name
    }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifier, for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }


}
