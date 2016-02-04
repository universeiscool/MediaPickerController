//
//  AlbumsViewController.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 23.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "AlbumTableViewCell"

public class AlbumsViewController: UITableViewController
{
    weak var delegate: AlbumsViewControllerDelegate?
    
    var albums:[[MediaPickerAlbum]]?
    
    var activeAlbums:[[MediaPickerAlbum]]?
    
    var hideMoments = false
    
    lazy var cachingManager:PHCachingImageManager? = {
        let manager = PHCachingImageManager.defaultManager() as? PHCachingImageManager
        manager?.allowsCachingHighQualityImages = false
        
        return manager
    }()
    
    convenience init(albums:[[MediaPickerAlbum]]?)
    {
        self.init(style:UITableViewStyle.Plain)
        self.albums = albums
        setup()
    }
    
    override private init(style: UITableViewStyle)
    {
        super.init(style: style)
        setup()
    }

    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit
    {
        print("deinit AlbumsViewController")
    }
    
    private func setup()
    {
        modalPresentationStyle = .Popover
    }
    
    override public func loadView()
    {
        super.loadView()
        
        let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light)))
        visualEffectView.frame = tableView.bounds
        visualEffectView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        tableView.backgroundView = visualEffectView
        tableView.backgroundColor = UIColor.clearColor()
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.scrollsToTop = true
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80.0
        tableView.registerClass(AlbumTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        activeAlbums = albums?.filter { hideMoments ? $0.first?.type != .Moments : true }
        tableView.reloadData()
    }
    
    public override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let albumCount = CGFloat(activeAlbums?.flatten().count ?? 0)
        preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, albumCount*80.0)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle
    {
            return .None
    }

    // MARK: UITableViewDataSource

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return activeAlbums?.count ?? 0
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activeAlbums?[section].count ?? 0
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumTableViewCell

        guard let album = activeAlbums?[indexPath.section][indexPath.row] else {
            cell.bind("", amount: 0)
            return cell
        }
        
        let manager = PHImageManager.defaultManager()
        
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        cell.bind(album.title ?? "", amount: album.assetCount)
        cell.selectionStyle = .None
        
        // Fetch cover photo
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        
        if let collection = album.collection where album.cover == nil {
            let result = PHAsset.fetchAssetsInAssetCollection(collection, options: fetchOptions)
            
            if let coverAsset = result.firstObject as? PHAsset {
                cell.tag = Int(manager.requestImageForAsset(coverAsset, targetSize: CGSize(width: 78, height: 78), contentMode: PHImageContentMode.AspectFill, options: nil) { (image:UIImage?, _) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let image = image, cell = tableView.cellForRowAtIndexPath(indexPath) as? AlbumTableViewCell {
                            cell.coverImageView.image = image
                            album.cover = image
                            cell.layoutSubviews()
                        }
                    }
                })
            }
        } else if let coverImage = album.cover {
            cell.coverImageView.image = coverImage
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        guard let album = activeAlbums?[indexPath.section][indexPath.row] else {
            return
        }
        
        delegate?.didSelectAlbum(album)
    }
}

protocol AlbumsViewControllerDelegate: class
{
    func didSelectAlbum(album:MediaPickerAlbum)
}