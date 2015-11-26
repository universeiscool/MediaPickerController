//
//  MomentsCollectionViewHeader.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

class MomentsCollectionViewHeader: UICollectionReusableView
{
    lazy var titleView:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14.0)
        return label
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        addSubview(titleView)
        let views = ["title":titleView]
        let constraints = [
            "H:|-(15)-[title]-(15)-|",
            "V:|-(5)-[title]-(5)-|"
        ].flatMap {
            NSLayoutConstraint.constraintsWithVisualFormat($0, options: [], metrics: nil, views: views)
        }
        
        addConstraints(constraints)
    }
    
    func bind(title:String, date:String)
    {
        titleView.text = !title.isEmpty ? title : date
    }
}
