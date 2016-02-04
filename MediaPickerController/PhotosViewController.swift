//
//  PhotosViewController.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 23.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

private let kReuseIdentifier = "PhotoCollectionViewCell"

public class PhotosViewController: MediaPickerCollectionViewController
{
    override public var album: MediaPickerAlbum? {
        didSet {
            collectionView?.setContentOffset(CGPointZero, animated: false)
            fetchResult = nil
            guard let collection = album?.collection else { return }
            mediaPickerController.selectAlbumButtonTitle = "\(album?.title ?? "") ▾"
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            self.collectionView?.reloadData()
        }
    }
    
    var fetchResult:PHFetchResult?
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView!.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: kReuseIdentifier)
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        mediaPickerController.doneButtonView.enabled = !mediaPickerController.selectedAssets.isEmpty
        
        if album != nil && fetchResult != nil {
            collectionView?.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource

    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchResult?.count ?? 0
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kReuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        if cell.tag != 0 {
            cachingImageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = fetchResult?[indexPath.row] as? PHAsset {
            if mediaPickerController.selectedAssets.indexOf(asset) != nil {
                cell.selected = true
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            } else {
                cell.selected = false
            }
            if mediaPickerController.prevSelectedAssetIdentifiers?.indexOf(asset.localIdentifier) != nil {
                cell.enabled = false
            }
            
            cell.tag = Int(cachingImageManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.bind(result)
            })
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        guard let asset = fetchResult?[indexPath.row] as? PHAsset else {
            return
        }
        
        mediaPickerController.selectedAssets.append(asset)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell
        cell?.setNeedsDisplay()
    }

    override public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        if(!cell.enabled){
            return false
        } else if mediaPickerController.selectedAssets.count == mediaPickerController.maximumSelect {
            return false
        }
        return true
    }
    
    override public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    public override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        guard let asset = fetchResult?[indexPath.row] as? PHAsset else {
            return
        }
        
        if let index = mediaPickerController.selectedAssets.indexOf(asset) {
            mediaPickerController.selectedAssets.removeAtIndex(index)
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell
        cell?.setNeedsDisplay()
    }
}