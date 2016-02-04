//
//  MediaPickerController.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 22.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit
import Photos

public enum MediaPickerOption
{
    case ViewBackgroundColor(UIColor)
    case NavigationBarTitleAttributes([String:AnyObject])
}

public enum MediaPickerAlbumType
{
    case Moments
    case Selected
    case AllAssets
    case UserAlbum
    case Panorama
    case Screenshots
    case Favorites
    case RecentlyAdded
    case SelfPortraits
    
    static func convertFromAssetTypes(assetCollectionSubtype: PHAssetCollectionSubtype) -> MediaPickerAlbumType?
    {
        var type:MediaPickerAlbumType? = nil
    
        switch assetCollectionSubtype {
        case .SmartAlbumPanoramas: type = .Panorama
        case .SmartAlbumRecentlyAdded: type = .RecentlyAdded
        case .SmartAlbumScreenshots: type = .Screenshots
        case .SmartAlbumSelfPortraits: type = .SelfPortraits
        case .SmartAlbumFavorites: type = .Favorites
        case .SmartAlbumUserLibrary: type = .AllAssets
        case .AlbumRegular: type = .UserAlbum
        default: type = nil
        }
        
        return type
    }
}

public class MediaPickerAlbum
{
    var title: String?
    var cover: UIImage?
    var collection: PHAssetCollection?
    var fetchResult: PHFetchResult? // For Moments
    var assetCount: Int
    var type: MediaPickerAlbumType
    
    init(title:String?, collection:PHAssetCollection?, assetCount:Int, type: MediaPickerAlbumType)
    {
        self.title = title
        self.collection = collection
        self.assetCount = assetCount
        self.type = type
    }
}

public struct MediaPickerMoment
{
    let title:String
    let date:String
    let assets:PHFetchResult
}

public class MediaPickerController: UINavigationController
{
    public var selectedAssets = [PHAsset]() {
        didSet {
            doneButtonView.enabled = selectedAssets.count > 0
        }
    }
    
    public var prevSelectedAssetIdentifiers:[String]?
    
    lazy var doneButtonView:UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("didClickDoneButton:"))
        button.enabled = false
        return button
    }()
    
    lazy var cancelButtonView:UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("didClickCancelButton:"))
    }()
    
    lazy var selectAlbumButtonView: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: Selector("didClickSelectAlbumButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.enabled = false
        return button
    }()
    
    var selectAlbumButtonTitle:String {
        set {
            let attributedTitle = NSAttributedString(string: newValue.uppercaseString, attributes: navigationBarTitleAttributes)
            selectAlbumButtonView.setAttributedTitle(attributedTitle, forState: .Normal)
            selectAlbumButtonView.sizeToFit()
        }
        get {
            return selectAlbumButtonView.titleLabel?.text ?? ""
        }
    }
    
    lazy public var photosViewController: PhotosViewController = {
        let vc = PhotosViewController()
        return vc
    }()
    
    lazy public var momentsViewController: MomentsViewController = {
        let vc = MomentsViewController()
        return vc
    }()
    
    lazy public var albumsViewController: AlbumsViewController = {
        let vc = AlbumsViewController(albums: self.albums)
        vc.preferredContentSize = self.view.bounds.size
        vc.delegate = self
        return vc
    }()
    
    var albums: [[MediaPickerAlbum]]?
    
    public var doneClosure:((assets: [PHAsset], momentTitle:String?, mediaPickerController:MediaPickerController) -> Void)?
    public var cancelClosure:((mediaPickerController:MediaPickerController) -> Void)?
    
    public var maximumSelect = Int(50) {
        didSet {
            allowsMultipleSelection = maximumSelect > 1
        }
    }
    public var allowsMultipleSelection = true
    public var viewBackgroundColor = UIColor.blackColor()
    public var navigationBarTitleAttributes:[String:AnyObject] = [
        NSForegroundColorAttributeName: UIColor.blackColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 16.0)!,
        NSKernAttributeName: 1.5
    ]
    public var hintText:String?
    
    public convenience init(mediaPickerOptions:[MediaPickerOption]?)
    {
        self.init(nibName: nil, bundle: nil)
        
        if let options = mediaPickerOptions {
            optionsToInstanceVariables(options)
        }
    }
    
    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        selectAlbumButtonTitle = "Loading ..."
        
        let fetcher = AlbumFetcher.shared
        fetcher.fetchAlbums{ (albums) in
            self.selectAlbumButtonView.enabled = true
            self.albums = albums
            if let album = self.albums?.flatten().filter({ $0.type == .Moments }).first {
                self.momentsViewController.album = album
            } else if let album = self.albums?.flatten().first {
                self.setViewControllers([self.photosViewController], animated: false)
                self.photosViewController.album = album
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        // Make sure MomentsViewController won't be displayed, if allowsMultipleSelection is not allowed
        if albums?.count > 0 && !allowsMultipleSelection {
            if getActiveViewController() is MomentsViewController {
                setViewControllers([photosViewController], animated: false)
                if let album = self.albums?.flatten().filter({ $0.type == .AllAssets }).first where photosViewController.album == nil {
                    self.photosViewController.album = album
                }
            }
        }
    }
    
    public override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
        selectedAssets.removeAll()
    }

    override public func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func loadView()
    {
        super.loadView()
        
        navigationBar.translucent = false
        
        setViewControllers([momentsViewController], animated: false)
    }
    
    func didClickSelectAlbumButton(sender: UIButton)
    {
        guard let popover = albumsViewController.popoverPresentationController else {
            return
        }
        
        popover.permittedArrowDirections = .Up
        popover.sourceView = sender
        let senderRect = sender.convertRect(sender.frame, fromView: sender.superview)
        let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + 4.0, width: senderRect.size.width, height: senderRect.size.height)
        popover.sourceRect = sourceRect
        popover.delegate = self
        
        albumsViewController.hideMoments = !allowsMultipleSelection
        
        presentViewController(albumsViewController, animated: true, completion: nil)
    }
    
    func didClickDoneButton(sender: UIBarButtonItem)
    {
        if let vc = viewControllers.first as? MomentsViewController {
            if let moment = vc.selectedMoment {
                var assets = [PHAsset]()
                for i in 0..<moment.assets.count {
                    assets.append(moment.assets[i] as! PHAsset)
                }
                doneClosure?(assets:assets, momentTitle:moment.title, mediaPickerController:self)
            }
        } else if let _ = viewControllers.first as? PhotosViewController {
            doneClosure?(assets:selectedAssets, momentTitle:nil, mediaPickerController:self)
        }
    }
    
    func didClickCancelButton(sender: UIBarButtonItem)
    {
        cancelClosure?(mediaPickerController:self)
    }
    
    // MARK: Helper Functions
    
    private func optionsToInstanceVariables(options:[MediaPickerOption])
    {
        for option in options {
            switch option {
            case let .ViewBackgroundColor(value): viewBackgroundColor = value
            case let .NavigationBarTitleAttributes(value): navigationBarTitleAttributes = value
            }
        }
    }
    
    private func getActiveViewController() -> MediaPickerCollectionViewController?
    {
        if let vc = viewControllers.first as? MomentsViewController {
            return vc
        } else if let vc = viewControllers.first as? PhotosViewController {
            return vc
        }
        return nil
    }
}

extension MediaPickerController: PHPhotoLibraryChangeObserver
{
    public func photoLibraryDidChange(changeInstance: PHChange)
    {
        
    }
}

// MARK: UIPopoverPresentationControllerDelegate

extension MediaPickerController: UIPopoverPresentationControllerDelegate
{
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    public func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool
    {
        return true
    }
}

// MARK: UINavigationControllerDelegate
//extension PhotosViewController: UINavigationControllerDelegate {
//    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if operation == .Push {
//            return expandAnimator
//        } else {
//            return shrinkAnimator
//        }
//    }
//}

extension MediaPickerController: AlbumsViewControllerDelegate
{
    func didSelectAlbum(album:MediaPickerAlbum)
    {
        self.albumsViewController.dismissViewControllerAnimated(true, completion: nil)
        if album.type == .Moments {
            self.setViewControllers([self.momentsViewController], animated: false)
            self.momentsViewController.album = album
        } else {
            self.setViewControllers([self.photosViewController], animated: false)
            self.photosViewController.album = album
        }
    }
}