//
//  AlbumTableViewCell.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 23.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    let kThumbnailLength: CGFloat = 78.0
    
    lazy var coverImageView:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = UIViewContentMode.ScaleAspectFill
        return view
    }()
    
    lazy var titleLabelView:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self.textLabel?.font
        return label
    }()
    
    lazy var subtitleLabelView:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self.detailTextLabel?.font
        label.textColor = UIColor.grayColor()
        return label
    }()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        opaque = true
        isAccessibilityElement = true
        textLabel?.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        layoutMargins = UIEdgeInsets(top: 0, left: 80.0, bottom: 0, right: 0)
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabelView)
        contentView.addSubview(subtitleLabelView)
        
        imageView?.backgroundColor = UIColor.lightGrayColor()
        imageView?.clipsToBounds = true
        
        let views = ["coverImageView": coverImageView, "titleLabelView": titleLabelView, "subtitleLabelView": subtitleLabelView]
        let metrics = ["padding": 10, "coversize":60]
        let constraints = [
            "H:|-(padding)-[coverImageView(coversize)]-(15)-[titleLabelView]",
            "H:[coverImageView]-(15)-[subtitleLabelView]",
            "V:|-(padding)-[coverImageView(coversize)]",
            "V:|-(>=20)-[titleLabelView]-(3)-[subtitleLabelView]-(>=20)-|",
        ].flatMap {
            NSLayoutConstraint.constraintsWithVisualFormat($0, options: NSLayoutFormatOptions(), metrics: metrics, views: views)
        }
        
        contentView.addConstraints(constraints)
    }
    
    func bind(title:String, amount:Int)
    {
        titleLabelView.text = title
        subtitleLabelView.text = amount != NSNotFound ? String(amount) : ""
        
//        let scale = CGFloat(CGImageGetHeight(image))/kThumbnailLength
//        self.imageView?.image = UIImage(CGImage: image, scale:scale, orientation: UIImageOrientation.Up)
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse()
    {
        //super.prepareForReuse()
        imageView?.image = nil
    }
}
