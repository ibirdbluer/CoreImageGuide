//
//  FilterListVC.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 24/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import UIKit
import CoreImage

protocol FilterSelectionDelegate: class {
    func filterSelected(name: String)
}

class FilterListVC: UITableViewController {

    weak var delegate: FilterSelectionDelegate?
    var filters: [String : [String]] = [:]
    let filterCategories = FilterQuery.filterCategory()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let result = FilterQuery.systemFilterList(categories: filterCategories) {
            filters = result
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterCategories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filters = filters[filterCategories[section]] {
            return filters.count
        }else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)

        guard let filterName = filters[filterCategories[indexPath.section]]?[indexPath.row] else {
            return cell
        }
        guard let localizedName = CIFilter.localizedName(forFilterName: filterName) else {
            return cell
        }
        
        cell.textLabel?.text = localizedName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let name = filters[filterCategories[indexPath.section]]?[indexPath.row] {
            self.delegate?.filterSelected(name: name)
            showDetailViewController(self.delegate as! UIViewController, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = CIFilter.localizedName(forCategory: filterCategories[section])
        return title
    }
    

}
