//
//  CategoryCollectionViewCell.swift
//  Realm Shop
//
//  Created by Konstantin Dmitrievskiy on 19.06.2021.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    private var isAnimate: Bool! = true

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!

    static func nib() -> UINib {
        return UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryLabel.font = UIFont(name: "Marker felt", size: 20)
    }

    func startAnimate() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 99_999

        let startAngle: Float = (-2) * 3.14 / 180
        let stopAngle = -startAngle

        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.timeOffset = 290 * Double.random(in: 0.0...1.0)

        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey: "animate")
        removeButton.isHidden = false
        isAnimate = true
    }

    func stopAnimate() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "animate")
        self.removeButton.isHidden = true
        isAnimate = false
    }
}
