//
//  AlbumFetcher.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import Foundation
import Photos

public class AlbumFetcher
{
    public static let shared = AlbumFetcher()
    
    private var albums = [[MediaPickerAlbum]]()
    
    private init()
    {
    }
    
    public func fetchAlbums(completion:((albums: [[MediaPickerAlbum]]) -> Void))
    {
        guard albums.count == 0 else {
            return completion(albums: albums)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let momentsFetchOptions = PHFetchOptions()
            momentsFetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > %d", 1)
            let moments = PHAssetCollection.fetchMomentsWithOptions(momentsFetchOptions)
            let fetchOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: fetchOptions)
            let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            
            // Moments
            let momentsAlbum = MediaPickerAlbum(title: "Moments", collection: moments.lastObject as? PHAssetCollection, assetCount: moments.count, type: MediaPickerAlbumType.Moments)
            momentsAlbum.fetchResult = moments
            if momentsAlbum.assetCount > 0 {
                self.albums.append([momentsAlbum])
            }
            
            // Smart albums / seperate allasset album
            let convertedSmartAlbums = self.convertAlbumFetchResult(smartAlbums)
            
            // Put AllAssets into seperate array
            let allAssets = convertedSmartAlbums.filter({ $0.type == MediaPickerAlbumType.AllAssets })
            if allAssets.count == 1 {
                self.albums.append(allAssets)
                self.albums.append(convertedSmartAlbums.filter({$0.type != MediaPickerAlbumType.AllAssets }))
            }
            
            // User created Albums
            self.albums.append(self.convertAlbumFetchResult(userAlbums))
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(albums: self.albums)
            }
        }
    }
    
    private func convertAlbumFetchResult(fetchResult:PHFetchResult) -> [MediaPickerAlbum]
    {
        var albums = [MediaPickerAlbum]()
        for i in 0..<fetchResult.count {
            guard let collection = fetchResult[i] as? PHAssetCollection else {
                continue
            }
            
            let type = MediaPickerAlbumType.convertFromAssetTypes(collection.assetCollectionSubtype)
            let assetCount = assetsCountFromCollection(collection)
            let title = collection.localizedTitle
            
            if let type = type where assetCount > 0 {
                albums.append(MediaPickerAlbum(title: title, collection: collection, assetCount: assetCount, type: type))
            }
        }
        return albums
    }
    
    private func assetsCountFromCollection(collection: PHAssetCollection?) -> Int
    {
        var count:Int
        
        if let estimatedCount = collection?.estimatedAssetCount where estimatedCount != NSNotFound {
            count = estimatedCount
        } else {
            let fetchResult = (collection == nil) ? PHAsset.fetchAssetsWithMediaType(.Image, options: nil) : PHAsset.fetchAssetsInAssetCollection(collection!, options: nil)
            count = fetchResult.count
        }
        
        return count
    }
}
