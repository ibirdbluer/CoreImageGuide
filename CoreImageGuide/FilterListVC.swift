//
//  FilterListVC.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 24/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import UIKit
import CoreImage

//protocol FilterSelectionDelegate: class {
//    func filterSelected(name: String)
//}

class FilterListVC: UITableViewController {

    var detailViewController: OutputVC?

//    weak var delegate: FilterSelectionDelegate?
    var filters: [String : [String]] = [:]
    let filterCategories = FilterQuery.filterCategory()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? OutputVC
        }
        
        if let result = FilterQuery.systemFilterList(categories: filterCategories) {
            filters = result
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
                if let name = filters[filterCategories[indexPath.section]]?[indexPath.row] {
                    let controller = (segue.destination as! UINavigationController).topViewController as! OutputVC
                    controller.filterName = name
                }
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
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
        tableView.deselectRow(at: indexPath, animated: true)
//        if let name = filters[filterCategories[indexPath.section]]?[indexPath.row] {
////            self.delegate?.filterSelected(name: name)
//            showDetailViewController(self.delegate as! UIViewController, sender: nil)
//        }
    }
    
//    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        cell.contentView.backgroundColor = .white
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = CIFilter.localizedName(forCategory: filterCategories[section])
        return title
    }
    

}
