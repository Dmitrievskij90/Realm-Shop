//
//  ItemScreenPresenter.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 02.08.2021.
//

import RealmSwift
import UIKit

class ItemScreenPresenter {
    private var priceArray = [Double]()
    private var purchaseAmount: Double = 0
    private var items: Results<Item>?
    private let realmManager: RealmManagerProtocol = RealmManager()
    private let view: ItemViewController
    weak var delegate: UIViewController?

    init(view: ItemViewController) {
        self.view = view
    }

    func setViewDelegate(delegate: UIViewController) {
        self.delegate = delegate
    }

    func addButonPressed() {
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
        delegate?.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }

    @objc func alertControllerBackgroundTapped() {
        self.delegate?.dismiss(animated: true, completion: nil)
    }

    func getDataFromSelectedCategory() -> Double {
        priceArray = [Double]()
        purchaseAmount = 0.0
        if let items = view.selectedCategory?.items {
            for i in items {
                let item = Double(i.price)
                priceArray.append(item ?? 0)
            }
        } else {
            assert(true, "Can't find category")
        }
        purchaseAmount = priceArray.reduce(0, +)
        view.priceLabel.text = String.roundedNumber(purchaseAmount)
        view.countLabel.text = String(priceArray.count)
        return purchaseAmount
    }

    private func saveItems(_ title: String, price: String) {
        let data = realmManager.saveItems(title, price: price, category: view.selectedCategory)
        purchaseAmount += Double(price) ?? 0
        view.countLabel.text = String(data.items.count)
        view.priceLabel.text = String.roundedNumber(self.purchaseAmount)
        view.itemTableView.reloadData()
    }
    
    func deleteItems(indexPath: IndexPath) {
        realmManager.deleteItems(category: view.selectedCategory, indexPath: indexPath, purchaseAmount: purchaseAmount)
        view.priceLabel.text = String.roundedNumber(purchaseAmount)
        view.countLabel.text = String(view.selectedCategory?.items.count ?? 0)
        purchaseAmount = getDataFromSelectedCategory()
        view.itemTableView.reloadData()
    }

    func loadItems() -> Results<Item>? {
        items = view.selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        return items
    }
}
