//
//  MomentFetcher.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import Foundation
import Photos

public class MomentFetcher
{
    public func fetchMoments(result:PHFetchResult, completion:((moments: [MediaPickerMoment]) -> Void))
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var moments = [MediaPickerMoment]()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE, d. MMMM yyyy"
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
            
            for index in 0 ..< result.count {
                let moment = result[index] as! PHAssetCollection
                let assets = PHAsset.fetchAssetsInAssetCollection(moment, options: fetchOptions)
                
                if assets.count == 0 { continue }
                
                var titleElements = [String]()
                
                if let title = moment.localizedTitle as String? {
                    titleElements.append(title)
                }
                
                if let locationNames = moment.localizedLocationNames as [String]? {
                    titleElements.append(locationNames.joinWithSeparator(", "))
                }
                
                var date = ""
                if let startDate = moment.startDate {
                    date = dateFormatter.stringFromDate(startDate)
                }
 
                let title = titleElements.joinWithSeparator(" - ")
                
                moments.append(MediaPickerMoment(title: title, date: date, assets: assets))
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(moments: moments.reverse())
            }
        }
    }
}
