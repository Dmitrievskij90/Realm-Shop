//
//  CategoryViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import RealmSwift
import UIKit

class CategoryViewController: UIViewController {
    private let leftInset: CGFloat = 5
    private let topInset: CGFloat = 0
    private let realm = try! Realm()
    private var categories: Results<Category>?

    @IBOutlet weak var categoryCollectionView: UICollectionView!

    // MARK: - lifecycle methods
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .label

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)

        loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - action methods
    // MARK: -
    @objc func addButonPressed() {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { _ in
            if let title = textField.text {
            let newCategory = Category()
            newCategory.name = title
            self.save(category: newCategory)
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Data Manipulation methods
    // MARK: -
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error savin context\(error)")
        }

        self.categoryCollectionView.reloadData()
    }

    private func loadCategories() {
        categories = realm.objects(Category.self)

        categoryCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  methods
// MARK: -
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 10
        if let category = categories?[indexPath.row] {
            cell.categoryLabel.text = category.name
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 3) - 10, height: (view.frame.width / 3) - 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: topInset, left: leftInset, bottom: topInset, right: leftInset)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = ItemViewController.instantiate()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }
}
