//
//  CategoryViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import RealmSwift
import UIKit

class CategoryViewController: UIViewController {
    private var longPressedEnabled = false
    private var purchaseArray = [Double]()
    private var purchaseAmount: Double = 0
    private let leftInset: CGFloat = 5
    private let topInset: CGFloat = 0
    private var categories: Results<Category>?
    private var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            assert(true, "Can't find realm")
            return nil
        }
    }

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var allPriceLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - lifecycle methods
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        categoryCollectionView.addGestureRecognizer(longPressGesture)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .label

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)

        setupUI()
        loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        getPurchaseAmount()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetPurchaseAmount()
    }

    // MARK: - action methods
    // MARK: -
    @IBAction private func doneButtonPressed(_ sender: UIButton) {
        doneButton.isUserInteractionEnabled = true
        doneButton.isHidden = true
        longPressedEnabled = false

        self.categoryCollectionView.reloadData()
    }

    @objc func addButonPressed() {
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

        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - UI methods
    // MARK: -
    private func setupUI() {
        title = "Categories"

        allPriceLabel.clipsToBounds = true
        allPriceLabel.layer.cornerRadius = 10
        allPriceLabel.backgroundColor = .init(hex: 0x94D0CC)
        allPriceLabel.text = String.roundedNumber(purchaseAmount)

        doneButton.isHidden = true
    }

    // MARK: - Data Manipulation methods
    // MARK: -
    private func saveCategory(category: Category) {
        do {
            try realm?.write {
                realm?.add(category)
            }
        } catch {
            assert(true, "Error savin category\(error)")
        }

        self.categoryCollectionView.reloadData()
    }

    private func loadCategories() {
        categories = realm?.objects(Category.self)

        categoryCollectionView.reloadData()
    }

    private func getPurchaseAmount() {
        guard let items = realm?.objects(Item.self) else {
            return
        }
        for item in items {
            let drink = Double(item.price)
            purchaseArray.append(drink ?? 0)
        }
        purchaseAmount = purchaseArray.reduce(0, +)
        allPriceLabel.text = String.roundedNumber(purchaseAmount)
    }

    private func resetPurchaseAmount() {
        purchaseArray = [Double]()
        purchaseAmount = 0.0
    }

    // MARK: - LongTapGestureRecognizer methods
    // MARK: -
    @objc func longTap(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = categoryCollectionView.indexPathForItem(at: gesture.location(in: categoryCollectionView)) else {
                return
            }
            categoryCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            categoryCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: categoryCollectionView))
        case .ended:
            categoryCollectionView.endInteractiveMovement()
            doneButton.isHidden = false
            longPressedEnabled = true
            self.categoryCollectionView.reloadData()
        default:
            categoryCollectionView.cancelInteractiveMovement()
        }
    }

    @objc func removeButtonPressed(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: self.categoryCollectionView)
        guard let hitIndex = self.categoryCollectionView.indexPathForItem(at: hitPoint) else {
            return
        }

        guard let categoryArray = categories else {
            return
        }

        if let category = categories?[hitIndex.row] {
            do {
                try realm?.write {
                    realm?.delete(category.items)
                    realm?.delete(category)
                }
            } catch {
                assert(true, "Error Updating data: \(error)")
            }
        }

        if categoryArray.isEmpty {
            doneButton.isHidden = true
            longPressedEnabled = false
        }

        resetPurchaseAmount()
        getPurchaseAmount()
        self.categoryCollectionView.reloadData()
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
            cell.backgroundColor = .init(hex: category.colour)
        }

        cell.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)

        if longPressedEnabled {
            cell.startAnimate()
        } else {
            cell.stopAnimate()
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
        viewController.selectedCategory = categories?[indexPath.item]
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        longPressedEnabled = false
        categoryCollectionView.reloadData()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
