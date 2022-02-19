//
//  ItemViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import RealmSwift
import UIKit

class ItemViewController: UIViewController {
    private lazy var presenter = ItemScreenPresenter(view: self)
    private var items: Results<Item>?
    var selectedCategory: Category?

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!

    // MARK: - lifecycle methods
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(delegate: self)
        presenter.getDataFromSelectedCategory()
        setupUI()

        items = presenter.loadItems()

        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.register(ItemTableViewCell.nib(), forCellReuseIdentifier: ItemTableViewCell.identifier)
    }

    // MARK: - UI method
    // MARK: -
    private func setupUI() {
        title = selectedCategory?.name

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton

        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.prefersLargeTitles = true

        bottomView.backgroundColor = .init(hex: selectedCategory?.colour ?? 0x94D0CC)
        bottomView.layer.cornerRadius = 10
        bottomView.clipsToBounds = true
    }

    // MARK: - action methods
    // MARK: -
    @objc func addButonPressed() {
        presenter.addButonPressed()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource methods
// MARK: -
extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifier, for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }

        let number = "\(indexPath.row + 1)."

        if let item = selectedCategory?.items[indexPath.row] {
            cell.textLabel?.text = number
            cell.itemLabel?.text = item.title
            cell.priceLabel.text = item.price
        } else {
            cell.itemLabel?.text = "No items"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.deleteItems(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
