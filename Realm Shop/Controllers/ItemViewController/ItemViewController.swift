//
//  ItemViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 20.06.2021.
//

import RealmSwift
import UIKit

class ItemViewController: UIViewController {
    private var priceArray = [Double]()
    private var purchaseAmount: Double = 0
    private var items: Results<Item>?
    private var realm: Realm? {
        do {
        let realm = try Realm()
            return realm
        } catch {
            assert(true, "Can't find realm")
            return nil
        }
    }
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!

    // MARK: - lifecycle methods
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromSelectedCategory()
        setupUI()

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

        priceLabel.text = String.roundedNumber(purchaseAmount)
        countLabel.text = String(priceArray.count)
    }

    // MARK: - action methods
    // MARK: -
    @objc func addButonPressed() {
        var itemTextField = UITextField()
        var priceTextField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            alertTextField.autocapitalizationType = .words
            itemTextField = alertTextField
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add item price"
            alertTextField.keyboardType = .decimalPad
            priceTextField = alertTextField
        }

        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let title = itemTextField.text, let price = priceTextField.text {
                self.saveItems(title, price: price)
            } else {
                assert(true, "Wrong data from textField")
            }
        }
        alert.addAction(action)
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }

    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Data Manipulation methods
    // MARK: -
    private func getDataFromSelectedCategory() {
        if let items = selectedCategory?.items {
            for i in items {
                let item = Double(i.price)
                priceArray.append(item ?? 0)
            }
        } else {
            assert(true, "Can't find category")
        }
        purchaseAmount = priceArray.reduce(0, +)
    }

    private func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }

    private func saveItems(_ title: String, price: String) {
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm?.write {
                    let newItem = Item()
                    newItem.title = title
                    newItem.price = price
                    self.purchaseAmount += Double(price) ?? 0
                    currentCategory.items.append(newItem)
                    self.countLabel.text = String(currentCategory.items.count)
                    self.priceLabel.text = String.roundedNumber(self.purchaseAmount)
                }
            } catch {
                assert(true, "Error saving new items")
            }
        }
        itemTableView.reloadData()
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
        if let item = selectedCategory?.items[indexPath.row] {
            do {
                try realm?.write {
                    purchaseAmount -= Double(item.price) ?? 0
                    realm?.delete(item)
                    self.priceLabel.text = String.roundedNumber(purchaseAmount)
                    self.countLabel.text = String(selectedCategory?.items.count ?? 0)
                }
            } catch {
                assert(true, "Error Updating data: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
