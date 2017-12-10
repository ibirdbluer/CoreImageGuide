//
//  OutputVC.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 24/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import UIKit

class OutputVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var attributeBar: UITableView!
    
    var filterName: String?
    var coreImageStack = CoreImageStack()
    var filterAttributeDict = [String : [String : Any]]()
    var filterAttributeArray = [String]() // save filter parameter keys for showing in filter attribute bar and getting the key when value changed
    var attributeParameter = [String : Any]()   // filter attribute parameter
    
    var activeSliderValues = [Float]()
    var sliderValues = [Float]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateAttributesBar(name: String) {
        var parameters = [String : Any]()
        filterAttributeDict = [String : [String : Any]]()
        filterAttributeArray = [String]()
        
        guard let attributes = CIFilter(name: name)?.attributes else { return }

        
        for attribute in attributes.keys {
            if let attributeValue = attributes[attribute] as? [String : Any] {
                filterAttributeDict[attribute] = attributeValue
                filterAttributeArray.append(attribute)
                
            }
        }
        
        attributeBar.reloadData()
//        print("\(filterAttributeDict)\n")
        
    }
    
    
    let image = CIImage(image: UIImage(named: "IMG_1108.jpg")!)
    
    func updateOutput() {
        guard filterName != nil else {
            return
        }
        
        
        attributeParameter[kCIInputImageKey] = image
        if attributeParameter[kCIInputScaleKey] == nil {
            attributeParameter[kCIInputScaleKey] = 1
        }

//        let ciimage = coreImageStack.oldFilmEffect(inputImage: image!)
//        let group = DispatchGroup()
        
//        let queue = DispatchQueue(label: "myqueue", attributes: .concurrent)
//        queue.async {
            guard let ciimage = self.coreImageStack.commenFilter(name: self.filterName!, parameter: self.attributeParameter) else { return }
            guard let cgImage = self.coreImageStack.context.createCGImage(ciimage, from: ciimage.extent) else { return }
            self.activeSliderValues.removeAll()
            print("remove slider group")
            DispatchQueue.main.async {
                self.imageView.image = UIImage(cgImage: cgImage)
            }
//        }
//        group.leave()
    }

    // MARK: - Slider Action
    @IBAction func sliderValueChange(_ sender: UISlider) {
        guard let key = filterAttributeArray[sender.tag] as? String else { return }
        
        // caculate real value
        let max = filterAttributeDict[key]!["CIAttributeSliderMax"] as! Float
        let min = filterAttributeDict[key]!["CIAttributeSliderMin"] as! Float
        let length = max - min
        let realValue = length * sender.value + min
//        print(realValue)
        attributeParameter[key] = realValue
        
        activeSliderValues.append(realValue)
        sliderValues.append(realValue)

        print("add value: \(activeSliderValues.count)")
        if activeSliderValues.count == 1 {
            print("update output")
            let quene = DispatchQueue(label: "myqueue")
            quene.async {
                self.updateOutput()
            }
        }
    }

    
}

extension OutputVC: FilterSelectionDelegate {
    func filterSelected(name: String) {
        filterName = name
        self.updateAttributesBar(name: self.filterName!)
        let quene = DispatchQueue(label: "myqueue")
        quene.async {
            self.updateOutput()
        }
    }
}

extension OutputVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterAttributeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeholderCell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")
        let key = filterAttributeArray[indexPath.row]
        guard let attributeValueDict = filterAttributeDict[key] else { return placeholderCell! }

        guard let attrType = attributeValueDict["CIAttributeType"] as? String else { return placeholderCell! }
        if attrType == "CIAttributeTypeScalar" || attrType == "CIAttributeTypeDistance" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            cell.titleLabel.text = key
            
            let max = attributeValueDict["CIAttributeSliderMax"] as! Float
            let min = attributeValueDict["CIAttributeSliderMin"] as! Float
            let defaultValue = attributeValueDict["CIAttributeDefault"] as! Float
            
            cell.maxLabel.text = "\(attributeValueDict["CIAttributeSliderMax"] ?? "")"
            cell.minLabel.text = "\(attributeValueDict["CIAttributeSliderMin"] ?? "")"
            
            cell.slider.value = Float(defaultValue / (max - min))
            cell.slider.tag = indexPath.row

            return cell
        }else {
            return placeholderCell!
        }
        
    }
}

