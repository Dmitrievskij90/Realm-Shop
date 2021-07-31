//
//  CategoryScreenPresenter.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 29.07.2021.
//

import RealmSwift
import UIKit

protocol CategoryPresenterProtocol: AnyObject {
    func getCategory(categori: Results<Category>?)
}

typealias CategoryPresenterDelegate = CategoryPresenterProtocol & UIViewController

class CategoryScreenPresenter {
    private let realmManager: RealmManagerProtocol = RealmManager()
    private var purchaseArray = [Double]()
    private var purchaseAmount: Double = 0
    private var categories: Results<Category>?

    weak var delegate: CategoryPresenterDelegate?

    func setViewDelegate(delegate: CategoryPresenterDelegate) {
        self.delegate = delegate
    }

    // MARK: - Action methods
    // MARK: -
    func addButonPressed() {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { _ in
            if let title = textField.text {
                let newCategory = Category()
                newCategory.name = title
                newCategory.colour = newCategory.categoryBackground.randomElement() ?? 0x94D0CC
                self.saveCategory(category: newCategory)
            } else {
                assert(true, "Wrong data from textField")
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField
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

    func removeButtonPressed(category: Category) {
        realmManager.deleteCategory(category)
        resetPurchaseAmount()
    }

    // MARK: - Data Manipulation methods
    // MARK: -
    func saveCategory(category: Category) {
        realmManager.saveCategory(category: category)
        delegate?.getCategory(categori: categories)
    }

    func loadCategories() {
        categories = realmManager.loadCategories()
        delegate?.getCategory(categori: categories)
    }

    func getPurchaseAmount(label: UILabel) {
        let items = realmManager.loadAllItems()

        for item in items {
            let drink = Double(item.price)
            purchaseArray.append(drink ?? 0)
        }
        purchaseAmount = purchaseArray.reduce(0, +)
        label.text = String.roundedNumber(purchaseAmount)
    }

    func resetPurchaseAmount() {
        purchaseArray = [Double]()
        purchaseAmount = 0.0
    }
}
