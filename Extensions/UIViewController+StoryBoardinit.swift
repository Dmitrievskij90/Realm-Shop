//
//  UIViewController+StoryBoardinit.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import Foundation

import UIKit

extension UIViewController {
    static func instantiate() -> Self {
        let name = String(describing: Self.self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Can not find VC")
        }
        return viewController
    }
}
