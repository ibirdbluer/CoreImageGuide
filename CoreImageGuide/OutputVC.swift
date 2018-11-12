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
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    
    var filterName: String? = "" {
        didSet {
            self.updateAttributesBar(name: self.filterName!)
            let quene = DispatchQueue(label: "myqueue")
            quene.async {
                self.updateOutput()
            }
        }
    }
    var coreImageStack = CoreImageStack()
    var filterAttributeDict = [String : [String : Any]]()
    var filterAttributeArray: [String]! // save filter parameter keys for showing in filter attribute bar and getting the key when value changed
    var attributeBarDataArray = [String]()
    var attributeParameter = [String : Any]()   // filter attribute parameter
    
    var activeSliderValues = [Float]()
    var sliderValues = [Float]()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
//        imageView.isHidden = true
        
        attributeBar.tableFooterView = UIView()
        
        barHeightConstraint.constant = CGFloat(attributeBarDataArray.count * 32)
//        testFunctionSwiftFilter()
        
        
    }

    func testFunctionSwiftFilter() {
        let image = CIImage(image: UIImage(named: "WechatIMG1455.jpeg")!)!
        let radius = 5.0
        let color = UIColor.red.withAlphaComponent(0.2)
        let blurredImage = blur(radius: radius)(image)
        let overlaidImage = overlay(color: color)(blurredImage)
        self.imageView.image = UIImage(ciImage: overlaidImage)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateAttributesBar(name: String) {
        guard let dictArray = FilterQuery.generateAttributeBarItem(name: name) else { return }
        filterAttributeDict = [String : [String : Any]]()
        filterAttributeArray = [String]()
        
        attributeBarDataArray = dictArray[2] as! [String];
        filterAttributeArray = dictArray[1] as! [String];
        filterAttributeDict = dictArray[0] as! [String : [String : Any]];
    
       
//        if let bar = attributeBar {
//            attributeBar.reloadData()
//        }
        print("\n\n\(name)")
        for key in filterAttributeDict.keys {
            print("\n----\(key)-----")
            if let dict = filterAttributeDict[key] {
                for subkey in dict.keys {
                    print("\(subkey) : \(String(describing: dict[subkey]))")
                }
            }
        }
//        print("\(filterAttributeDict)\n")
    }
    
    
    let image = CIImage(image: UIImage(named: "youcan.jpg")!)
//    let image = CIImage(image: UIImage(named: "WechatIMG1455.jpeg")!)

    var lock = NSLock()
    var queueDidFinished = true
    let operationQueue = OperationQueue()

    func updateOutput() {
        guard filterName != nil else {
            return
        }
        
        
        attributeParameter[kCIInputImageKey] = image
//        if attributeParameter[kCIInputScaleKey] == nil {
//            attributeParameter[kCIInputScaleKey] = 1
//        }

//        let ciimage = coreImageStack.oldFilmEffect(inputImage: image!)
//        let group = DispatchGroup()
//        lock.lock()
        let queue = DispatchQueue(label: "myqueue", attributes: .concurrent)
        let operation = BlockOperation {
            if !self.queueDidFinished {
                print(0)
                return
            }
            print("1")
            self.queueDidFinished = false
            guard let ciimage = self.coreImageStack.commenFilter(name: self.filterName!, parameter: self.attributeParameter) else { return }
            guard let cgImage = self.coreImageStack.context.createCGImage(ciimage, from: ciimage.extent) else { return }
            DispatchQueue.main.sync {
                self.imageView.image = UIImage(cgImage: cgImage)
                self.queueDidFinished = true
                print(2)
            }
        }
        
        operation.completionBlock = {
            print(3)
        }
        
        operationQueue.addOperation(operation)
        
//        queue.sync {
//            if !queueDidFinished {
//
//            }
//            guard let ciimage = self.coreImageStack.commenFilter(name: self.filterName!, parameter: self.attributeParameter) else { return }
//            guard let cgImage = self.coreImageStack.context.createCGImage(ciimage, from: ciimage.extent) else { return }
//            self.activeSliderValues.removeAll()
//            print("remove slider group")
//            DispatchQueue.main.sync {
//                self.imageView.image = UIImage(cgImage: cgImage)
//            }
//        }
//        lock.unlock()
//        group.leave()
    }

    // MARK: - Slider Action
    @IBAction func sliderValueChange(_ sender: UISlider) {
        guard sender.tag < attributeBarDataArray.count else {return }
        let key = attributeBarDataArray[sender.tag]
        
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
//        if activeSliderValues.count == 1 {
            print("update output")
//            let quene = DispatchQueue(label: "myqueue")
//            quene.async {
                self.updateOutput()
//            }
//        }
    }
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self.imageView) else { return }
        guard filterAttributeArray.contains(kCIInputCenterKey) else { return }
        let vector = CommonDataHelper.cgPointToCIVector(point: touchPoint, baseSize: self.imageView.frame.size)
        attributeParameter[kCIInputCenterKey] = vector
        updateOutput()
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self.imageView) else { return }
        guard filterAttributeArray.contains(kCIInputCenterKey) else { return }
        let vector = CommonDataHelper.cgPointToCIVector(point: touchPoint, baseSize: self.imageView.frame.size)
        attributeParameter[kCIInputCenterKey] = vector
        updateOutput()
    }
    
}

//extension OutputVC: FilterSelectionDelegate {
//    func filterSelected(name: String) {
//        filterName = name
//        self.updateAttributesBar(name: self.filterName!)
//        let quene = DispatchQueue(label: "myqueue")
//        quene.async {
//            self.updateOutput()
//        }
//    }
//}

extension OutputVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributeBarDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeholderCell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")
        let key = attributeBarDataArray[indexPath.row]
        guard let attributeValueDict = filterAttributeDict[key] else { return placeholderCell! }

        guard let attrType = attributeValueDict["CIAttributeType"] as? String else { return placeholderCell! }
        if attrType == "CIAttributeTypeScalar" || attrType == "CIAttributeTypeDistance" || attrType == "CIAttributeTypeAngle"{
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
        }else if attrType == "CIAttributeTypePosition" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailDescriptionCell", for: indexPath) as! DetailDescriptionCell
            cell.theTitleLabel.text = key
            cell.theDetailLabel.text = "touch photo area"
            
            return cell

        }else {
            return placeholderCell!
        }
        
    }
}


