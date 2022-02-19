//
//  RealmManager.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 28.07.2021.
//

import RealmSwift
import UIKit

protocol RealmManagerProtocol {
    func saveCategory(category: Category)
    func loadCategories() -> Results<Category>?
    func saveItems(_ title: String, price: String, category: Category?) -> Category
    func loadItemsForSelectedCategory()
    func loadAllItems() -> Results<Item>
    func deleteCategory(_ category: Category)
    func deleteItems(category: Category?, indexPath: IndexPath, purchaseAmount: Double)
}

class RealmManager: RealmManagerProtocol {
    private var categories: Results<Category>?
    private var items: Results<Item>?
    private var selectedCategory: Category?
    private var realm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            assert(true, "Can't find realm")
            return nil
        }
    }

    // MARK: - Categories methods
    // MARK: -
    func saveCategory(category: Category) {
        do {
            try realm?.write {
                realm?.add(category)
            }
        } catch {
            assert(true, "Error saving category\(error)")
        }
    }

    func loadCategories() -> Results<Category>? {
        categories = realm?.objects(Category.self)
        return categories
    }

    func deleteCategory(_ category: Category) {
        do {
            try realm?.write {
                realm?.delete(category.items)
                realm?.delete(category)
            }
        } catch {
            assert(true, "Error Updating data: \(error)")
        }
    }

    // MARK: - Items methods
    // MARK: -
    func saveItems(_ title: String, price: String, category: Category?) -> Category {
        var result = Category()
        if let currentCategory = category {
            result = currentCategory
            do {
                try self.realm?.write {
                    let newItem = Item()
                    newItem.title = title
                    newItem.price = price
                    currentCategory.items.append(newItem)
                }
            } catch {
                assert(true, "Error saving new items")
            }
        }
        return result
    }

    func loadItemsForSelectedCategory() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }

    func loadAllItems() -> Results<Item> {
        guard let items = realm?.objects(Item.self) else {
            fatalError("Items is empty")
        }
        return items
    }

    func deleteItems(category: Category?, indexPath: IndexPath, purchaseAmount: Double) {
        var amount = purchaseAmount
        if let item = category?.items[indexPath.row] {
            do {
                try realm?.write {
                    amount -= Double(item.price) ?? 0
                    realm?.delete(item)
                }
            } catch {
                assert(true, "Error Updating data: \(error)")
            }
        }
    }
}
