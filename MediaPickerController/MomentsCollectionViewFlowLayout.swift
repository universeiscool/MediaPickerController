//
//  MomentsCollectionViewFlowLayout.swift
//  MediaPickerController
//
//  Created by Malte Schonvogel on 24.11.15.
//  Copyright © 2015 universeiscool UG (haftungsbeschränkt). All rights reserved.
//

import UIKit

let kDecorationReuseIdentifier = "MomentsCollectionViewDecoration"

class MomentsCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    var headerAttributes = [NSIndexPath:UICollectionViewLayoutAttributes]()
    var footerAttributes = [NSIndexPath:UICollectionViewLayoutAttributes]()
    var backgroundAttributes = [NSIndexPath:MediaPickerCollectionViewLayoutAttributes]()
    var cellAttributes = [NSIndexPath:UICollectionViewLayoutAttributes]()
    
    private var contentSize = CGSizeZero
    
    var viewPortWidth: CGFloat {
        get {
            return self.collectionView!.frame.width - self.collectionView!.contentInset.left - self.collectionView!.contentInset.right
        }
    }
    
    var viewPortAvailableSize: CGFloat {
        get {
            return self.viewPortWidth - self.sectionInset.left - self.sectionInset.right
        }
    }
    
    weak var delegate: MomentsCollectionViewFlowLayoutDelegate? {
        get{
            return self.collectionView!.delegate as? MomentsCollectionViewFlowLayoutDelegate
        }
    }
    
    // Caution! This prevents layout calculations
    var sizeOfViewsNeverChange:Bool = false
    
    override init()
    {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        registerClass(MomentsCollectionDecorationView.self, forDecorationViewOfKind: kDecorationReuseIdentifier)
    }
    
    override class func layoutAttributesClass() -> AnyClass
    {
        return MediaPickerCollectionViewLayoutAttributes.self
    }
    
    private func clearVariables()
    {
        headerAttributes.removeAll()
        cellAttributes.removeAll()
        footerAttributes.removeAll()
        backgroundAttributes.removeAll()
        contentSize = CGSizeZero
    }
    
    override func prepareLayout()
    {
        guard let sectionAmount = collectionView?.numberOfSections() else {
            return
        }
        
        if sectionAmount == 0 || (sizeOfViewsNeverChange && sectionAmount == backgroundAttributes.count && contentSize.width == viewPortWidth) {
            return
        }
        
        let itemsPerRow = Int(viewPortWidth / itemSize.width)
        
        
        // Initialize variables
        clearVariables()
        
        // Shortcut
        let viewWidth = collectionView!.bounds.width
        
        for section in 0..<sectionAmount {
            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            
            // HeaderSize
            let headerSize = referenceSizeForHeaderInSection(section)
            let hLa = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
            hLa.frame = CGRect(x: 0, y: contentSize.height, width: viewWidth, height: headerSize.height)
            headerAttributes[indexPath] = hLa
            
            // SectionSize
            let sectionOffset = CGPoint(x: 0, y: contentSize.height + headerSize.height)
            let itemsAmount:Int = collectionView!.numberOfItemsInSection(section)
            let fractions = fractionize(itemsAmount, itemsAmountPerRow: itemsPerRow, section: section)
            let sectionSize = setFramesForItems(fractions: fractions, section: section, sectionOffset: sectionOffset)
            
            // FooterSize
            let footerSize = referenceSizeForFooterInSection(section)
            let fLa = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withIndexPath: indexPath)
            fLa.frame = CGRect(x: 0, y: contentSize.height + headerSize.height + sectionSize.height, width: viewWidth, height: footerSize.height)
            footerAttributes[indexPath] = fLa
            
            // BackgroundSize
            let bLa = MediaPickerCollectionViewLayoutAttributes(forDecorationViewOfKind: kDecorationReuseIdentifier, withIndexPath: indexPath)
            bLa.frame = CGRect(x: 0, y: contentSize.height, width: viewWidth, height: headerSize.height + sectionSize.height - sectionInset.bottom)
            if let selected = delegate?.sectionIsSelected(section) {
                bLa.selected = selected
            }
            backgroundAttributes[indexPath] = bLa
            
            // ContentSize
            contentSize = CGSize(width: sectionSize.width, height: contentSize.height + headerSize.height + sectionSize.height + footerSize.height)
        }
    }
    
    private func fractionize(let amount:Int, itemsAmountPerRow:Int, section:Int) -> [[Int]]
    {
        var result = [[Int]]()
        if amount == 0 {
            return result
        }
        
        let rest:Int = amount % itemsAmountPerRow
        
        // Quick & Dirty
        if amount == rest {
            result.append((0..<amount).map({ $0 }))
        } else if rest > 0 && rest <= Int(ceil(Float(itemsAmountPerRow/2))) && amount >= rest + itemsAmountPerRow {
            let newRest = rest + itemsAmountPerRow
            let divider = Int(ceil(Float(newRest) / Float(itemsAmountPerRow/2)))
            result += (0..<newRest).map({$0}).splitBy(divider).reverse()
            result += (newRest..<amount).map({$0}).splitBy(itemsAmountPerRow)
        } else {
            let first = (0..<rest).map({ $0 })
            if !first.isEmpty {
                result.append(first)
            }
            let second = (rest..<amount).map({ $0 }).splitBy(itemsAmountPerRow)
            if !second.isEmpty {
                result += second
            }
        }
    
        return result
    }
    
    private func setFramesForItems(fractions fractions:[[Int]], section:Int, sectionOffset: CGPoint) -> CGSize
    {
        var contentMaxValueInScrollDirection = CGFloat(0)
        var offset = CGPoint(x: sectionOffset.x + sectionInset.left, y: sectionOffset.y + sectionInset.top)
        
        for fraction in fractions {
            let itemsPerRow = fraction.count
            let itemWidthHeight:CGFloat = (viewPortAvailableSize - minimumInteritemSpacing * CGFloat(itemsPerRow-1)) / CGFloat(itemsPerRow)
            offset.x = sectionOffset.x + sectionInset.left
            for itemIndex in fraction {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: section)
                let frame = CGRectMake(offset.x, offset.y, itemWidthHeight, itemWidthHeight)
                let la = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                la.frame = frame
                cellAttributes[indexPath] = la
                contentMaxValueInScrollDirection = CGRectGetMaxY(frame)
                offset.x += itemWidthHeight + minimumInteritemSpacing
            }
            offset.y += itemWidthHeight + minimumLineSpacing
        }
        
        return CGSize(width: viewPortWidth, height: contentMaxValueInScrollDirection - sectionOffset.y + sectionInset.bottom)
    }
    
    // MARK: Delegate Helpers
    
    private func referenceSizeForHeaderInSection(section:Int) -> CGSize
    {
        if let headerSize = self.delegate?.collectionView?(collectionView!, layout: self, referenceSizeForHeaderInSection: section){
            return headerSize
        }
        return headerReferenceSize
    }
    
    private func referenceSizeForFooterInSection(section:Int) -> CGSize
    {
        if let footerSize = self.delegate?.collectionView?(collectionView!, layout: self, referenceSizeForFooterInSection: section){
            return footerSize
        }
        return footerReferenceSize
    }
    
    
    override func collectionViewContentSize() -> CGSize
    {
        return contentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var lA = [UICollectionViewLayoutAttributes]()
        
        for var section = 0, numberOfSections = collectionView!.numberOfSections(); section < numberOfSections; ++section {
            let sectionIndexPath = NSIndexPath(forItem: 0, inSection: section)
            
            // HeaderAttributes
            if let hA = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: sectionIndexPath) where !CGSizeEqualToSize(hA.frame.size, CGSizeZero) && CGRectIntersectsRect(hA.frame, rect) {
                lA.append(hA)
            }
            
            // ItemAttributes
            for var item = 0, itemsInSection = collectionView!.numberOfItemsInSection(section); item < itemsInSection; ++item {
                if let la = cellAttributes[NSIndexPath(forItem: item, inSection: section)] where CGRectIntersectsRect(rect, la.frame) {
                    lA.append(la)
                }
            }
            
            // FooterAttributes
            if let fA = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: sectionIndexPath) where !CGSizeEqualToSize(fA.frame.size, CGSizeZero) && CGRectIntersectsRect(fA.frame, rect) {
                lA.append(fA)
            }
            
            // BackgroundAttributes
            if let bA = layoutAttributesForDecorationViewOfKind(kDecorationReuseIdentifier, atIndexPath: sectionIndexPath) where !CGSizeEqualToSize(bA.frame.size, CGSizeZero) && CGRectIntersectsRect(bA.frame, rect) {
                lA.append(bA)
            }
        }
        
        return lA
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cellAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            return headerAttributes[indexPath]
        case UICollectionElementKindSectionFooter:
            return footerAttributes[indexPath]
        default:
            return nil
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        let oldBounds = collectionView!.bounds
        if CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds) || CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds) {
            return true
        }
        return false
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let la = backgroundAttributes[indexPath]
        if let selected = delegate?.sectionIsSelected(indexPath.section) {
            la?.selected = selected
        }
        
        return la
    }
}

public protocol MomentsCollectionViewFlowLayoutDelegate: UICollectionViewDelegateFlowLayout
{
    func sectionIsSelected(section:Int) -> Bool
}

class MediaPickerCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes
{
    var selected = false
}

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return 0.stride(to: self.count, by: subSize).map { startIndex in
            let endIndex = startIndex.advancedBy(subSize, limit: self.count)
            return Array(self[startIndex ..< endIndex])
        }
    }
}