//
//  CategoryViewController.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import RealmSwift
import UIKit

class CategoryViewController: UIViewController {
    private lazy var presenter = CategoryScreenPresenter()
    private var categories: Results<Category>?
    private var longPressedEnabled = false

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var allPriceLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - lifecycle methods
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setViewDelegate(delegate: self)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        categoryCollectionView.addGestureRecognizer(longPressGesture)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonPressed))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .label

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)

        //              print(Realm.Configuration.defaultConfiguration.fileURL)

        setupUI()
        presenter.loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        resetPurchaseAmount()
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
        presenter.addButonPressed()
    }

    // MARK: - UI methods
    // MARK: -
    private func setupUI() {
        title = "Categories"

        allPriceLabel.clipsToBounds = true
        allPriceLabel.layer.cornerRadius = 10
        allPriceLabel.backgroundColor = .init(hex: 0x94D0CC)

        doneButton.isHidden = true

        presenter.getPurchaseAmount(label: allPriceLabel)
    }

    // MARK: - Data Manipulation methods
    // MARK: -
    private func getPurchaseAmount() {
        presenter.getPurchaseAmount(label: allPriceLabel)
    }

    private func resetPurchaseAmount() {
        presenter.resetPurchaseAmount()
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
            presenter.removeButtonPressed(category: category)
        } else {
            assert(true, "Can't remove category")
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
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
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

// MARK: - CategoryPresenterDelegate methods
// MARK: -
extension CategoryViewController: CategoryPresenterProtocol {
    func getCategory(categori: Results<Category>?) {
        self.categories = categori

        DispatchQueue.main.async {
            self.categoryCollectionView.reloadData()
        }
    }
}
