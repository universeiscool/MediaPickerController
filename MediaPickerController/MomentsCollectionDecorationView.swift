//
//  MomentsCollectionDecorationView.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

class MomentsCollectionDecorationView: UICollectionReusableView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        layer.borderColor = UIColor(red: 0, green: 155/255, blue: 255/255, alpha: 1).CGColor
        layer.borderWidth = 0
        layer.zPosition = 1
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes)
    {
        super.applyLayoutAttributes(layoutAttributes)
        if let lA = layoutAttributes as? MediaPickerCollectionViewLayoutAttributes where lA.selected {
            layer.borderWidth = 5
        } else {
            layer.borderWidth = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}