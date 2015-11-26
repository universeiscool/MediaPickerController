//
//  MediaPickerCollectionViewController.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

public class MediaPickerCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    let cachingImageManager = PHCachingImageManager()
    var mediaPickerController: MediaPickerController {
        get {
            return self.parentViewController as! MediaPickerController
        }
    }
    
    var cellsPerRow: (verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
        switch (verticalSize, horizontalSize) {
        case (.Compact, .Regular): // iPhone5-6 portrait
            return 4
        case (.Compact, .Compact): // iPhone5-6 landscape
            return 6
        case (.Regular, .Regular): // iPad portrait/landscape
            return 8
        default:
            return 4
        }
    }
    
    lazy var activityIndicator:UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .White)
        ai.hidden = true
        ai.center = self.view.center
        return ai
    }()
    
    var imageSize = CGSizeZero
    var imageContentMode = PHImageContentMode.AspectFill
    var album: MediaPickerAlbum?
    
    init()
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        super.init(collectionViewLayout:layout)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = mediaPickerController.doneButtonView
        navigationItem.leftBarButtonItem = mediaPickerController.cancelButtonView
        navigationItem.titleView = mediaPickerController.selectAlbumButtonView
        collectionView?.backgroundColor = mediaPickerController.viewBackgroundColor
        collectionView?.allowsMultipleSelection = mediaPickerController.allowsMultipleSelection
    }
    
    func showActivityIndicator()
    {
        view.insertSubview(activityIndicator, aboveSubview: collectionView!)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    override public func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout, collectionView = collectionView else {
            return
        }
        
        let cellsPerRow = self.cellsPerRow(verticalSize: traitCollection.verticalSizeClass, horizontalSize: traitCollection.horizontalSizeClass)
        let itemSpacing = CGFloat(1)
        let itemLegth = (collectionView.bounds.width - CGFloat(cellsPerRow) * itemSpacing) / CGFloat(cellsPerRow)
        
        imageSize = CGSize(width: itemLegth, height: itemLegth)
        collectionViewFlowLayout.itemSize = imageSize
        
        activityIndicator.center = collectionView.center
    }
}