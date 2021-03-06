//
//  FilterQuery.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 24/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import Foundation
import CoreImage

class FilterQuery {
    
    
    class func filterCategory() -> [String] {
        let effectTypeFilterCategory = [
            kCICategoryDistortionEffect,
            kCICategoryGeometryAdjustment,
            kCICategoryCompositeOperation,
            kCICategoryHalftoneEffect,
            kCICategoryColorAdjustment,
            kCICategoryColorEffect,
            kCICategoryTransition,
            kCICategoryTileEffect,
            kCICategoryGenerator,
            kCICategoryGradient,
            kCICategoryStylize,
            kCICategorySharpen,
            kCICategoryBlur
        ]
        return effectTypeFilterCategory
    }
    
    class func querySystemFilters(categories: [String]?) -> [String]? {
        var filters: [String]?
        if categories == nil {
            filters = CIFilter.filterNames(inCategory: nil)
        }else if categories?.count == 1 {
            filters = CIFilter.filterNames(inCategory: categories?.first)
        }else if (categories?.count)! > 1 {
            filters = CIFilter.filterNames(inCategories: categories)
        }
        return filters
    }
    
    class func systemFilterList(categories: [String]) -> [String : [String]]? {
        var filterList = [String : [String]]()
        for category in categories {
            if let filters = querySystemFilters(categories: [category]) {
                filterList[category] = filters
            }
        }
        return filterList
    }
    
    class func generateAttributeBarItem(name: String) -> [Any]? {
        guard let attributes = CIFilter(name: name)?.attributes else { return nil }
        var filterAttributeDict = [String : [String : Any]]()
        var filterAttributeArray = [String]()
        var attributeBarDataArray = [String]()
        
        for attribute in attributes.keys {
            if let attributeValue = attributes[attribute] as? [String : Any] {
                filterAttributeDict[attribute] = attributeValue
                filterAttributeArray.append(attribute)
                if determineIsFilterAttributeBarItem(name: attribute) {
                    attributeBarDataArray.append(attribute)
                }
            }
        }
        return [filterAttributeDict, filterAttributeArray, attributeBarDataArray]
    }
    
    private class func determineIsFilterAttributeBarItem(name: String) -> Bool {
        if name == kCIInputImageKey {
            return false
        }
        return true
    }
//    class func localizedName(forFilterName filterName: String) -> String? {
//        return CIFilter.localizedName(forFilterName: filterName)
//    }
//    
//    class func filterAttributes(name: String) -> [String : Any]? {
//        guard let filter = CIFilter(name: name) else { return nil }
//        return filter.attributes
//    }
}


