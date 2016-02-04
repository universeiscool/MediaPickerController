//
//  PhotoCollectionViewCell.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 23.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

final class PhotoCollectionViewCell: UICollectionViewCell
{
    let kSelectedBorderColor = UIColor(red: 0, green: 155/255, blue: 255/255, alpha: 1).CGColor
    let kDisabledBorderColor = UIColor.grayColor().CGColor
    
    var image: UIImage?
    let checkedIcon = UIImage(named: "AssetsPickerChecked")
    
    lazy var imageView:UIImageView = {
        let view = UIImageView(frame: self.contentView.bounds)
        view.contentMode = UIViewContentMode.ScaleAspectFill
        view.clipsToBounds = true
        view.layer.borderColor = self.kSelectedBorderColor
        view.layer.borderWidth = 0
        return view
    }()
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            let hasChanged = selected != newValue
            super.selected = newValue
            
            if UIView.areAnimationsEnabled() && hasChanged {
                UIView.animateWithDuration(NSTimeInterval(0.1), animations: { () -> Void in
                    self.updateSelected(newValue)
                    // Scale all views down a little
                    self.transform = CGAffineTransformMakeScale(0.95, 0.95)
                    }) { (finished: Bool) -> Void in
                        UIView.animateWithDuration(NSTimeInterval(0.1), animations: { () -> Void in
                            // And then scale them back upp again to give a bounce effect
                            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            }, completion: nil)
                }
            } else {
                self.updateSelected(newValue)
            }
        }
    }
    
    var enabled = true {
        didSet {
            updateEnabled(enabled)
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        contentView.addSubview(imageView)
        opaque = true
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func bind(image:UIImage?)
    {
        imageView.image = image
        updateSelected(selected)
        updateEnabled(enabled)
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        imageView.image = nil
        enabled = true
    }
    
    private func updateSelected(selected:Bool)
    {
        imageView.alpha = selected ? 0.85 : 1.0
        imageView.layer.borderWidth = selected ? 4 : 0
    }
    
    private func updateEnabled(enabled:Bool)
    {
        imageView.layer.borderColor = enabled ? kSelectedBorderColor : kDisabledBorderColor
        imageView.layer.borderWidth = enabled ? 0 : 4
        imageView.alpha = enabled ? 1.0 : 0.85
    }
}