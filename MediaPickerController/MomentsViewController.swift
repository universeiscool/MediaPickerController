//
//  MomentsViewController.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

private let kCellReuseIdentifier = "MomentCollectionViewCell"
private let kHeaderReuseIdentifier = "MomentsCollectionViewHeader"
private let kFooterReuseIdentifier = "MomentsCollectionViewFooter"

public class MomentsViewController: MediaPickerCollectionViewController
{
    private var moments:[MediaPickerMoment]?
    
    private var selectedSection:Int? {
        didSet {
            mediaPickerController.doneButtonView.enabled = selectedSection != nil
            let sectionsToUpdate = NSMutableIndexSet()
            if let oldValue = oldValue {
                sectionsToUpdate.addIndex(oldValue)
            }
            if let selectedSection = selectedSection where oldValue != selectedSection {
                sectionsToUpdate.addIndex(selectedSection)
                collectionView?.reloadSections(sectionsToUpdate)
            }
        }
    }
    
    public var selectedMoment:MediaPickerMoment? {
        get {
            if let selectedSection = selectedSection {
                return moments?[selectedSection]
            }
            return nil
        }
    }
    
    private lazy var selectSectionGesture:UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(selectSection(_:)))
        gr.cancelsTouchesInView = true
        return gr
    }()
    
    override init()
    {
        let layout = MomentsCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 30.0, right: 0)
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        layout.sizeOfViewsNeverChange = true
        super.init(collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var album: MediaPickerAlbum? {
        didSet {
            collectionView?.setContentOffset(CGPointZero, animated: false)
            mediaPickerController.selectAlbumButtonTitle = "\(album?.title ?? "") ▾"
            if let fetchResult = album?.fetchResult where moments == nil {
                let fetcher = MomentFetcher.shared
                fetcher.fetchMoments(fetchResult) { (moments:[MediaPickerMoment]) in
                    self.moments = moments
                    self.collectionView?.reloadData()
                    if !moments.isEmpty {
                        self.selectedSection = 0
                    }
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView!.allowsMultipleSelection = false
        collectionView!.allowsSelection = false
        collectionView!.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView!.registerClass(MomentsCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier)
        collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier)
        
        showActivityIndicator()
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        collectionView?.addGestureRecognizer(selectSectionGesture)

        if selectedSection != nil {
            mediaPickerController.doneButtonView.enabled = true
        }
        if moments != nil {
            collectionView?.reloadData()
        }
    }
    
    public override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        collectionView?.removeGestureRecognizer(selectSectionGesture)
    }
    
    func selectSection(sender: UITapGestureRecognizer)
    {
        if let indexPath = collectionView?.indexPathForItemAtPoint(sender.locationInView(collectionView)) {
            selectedSection = indexPath.section
        }
    }
    
    private func selectSectionAtIndexPath(indexPath:NSIndexPath)
    {
        let sectionsToUpdate = NSMutableIndexSet()
        
        if let lastSelected = selectedSection {
            sectionsToUpdate.addIndex(lastSelected)
        }
        if selectedSection != indexPath.section {
            selectedSection = indexPath.section
            sectionsToUpdate.addIndex(indexPath.section)
        } else {
            selectedSection = nil
        }
        collectionView?.reloadSections(sectionsToUpdate)
    }
}

// MARK: UICollectionViewDataSource

extension MomentsViewController
{
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return moments?.count ?? 0
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return moments?[section].assets.count ?? 0
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        if cell.tag != 0 {
            cachingImageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = moments?[indexPath.section].assets[indexPath.row] as? PHAsset {
            cell.tag = Int(cachingImageManager.requestImageForAsset(asset, targetSize: cell.frame.size, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.bind(result)
            })
        }
        
        return cell
    }
    
    public override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuseIdentifier, forIndexPath: indexPath) as! MomentsCollectionViewHeader
            if let moment = moments?[indexPath.section] {
                view.bind(moment.title, date: moment.date)
            }
            return view
        } else {
            return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: kFooterReuseIdentifier, forIndexPath: indexPath)
        }
    }
}

extension MomentsViewController
{
    override public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
}

extension MomentsViewController: MomentsCollectionViewFlowLayoutDelegate
{
    public func sectionIsSelected(section: Int) -> Bool
    {
        return selectedSection == section
    }
}