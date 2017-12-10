//
//  CoreImageStack.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 24/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import Foundation
import CoreImage

class CoreImageStack {
    
    lazy var device = MTLCreateSystemDefaultDevice()
    
    lazy var commandQueue: MTLCommandQueue =
        {
            return self.device!.makeCommandQueue()
    }()
    
    lazy var ciContext: CIContext =
        {
            return CIContext(mtlDevice: self.device!)
    }()
    
    lazy var context: CIContext = {
        
//        return CIContext()
//        return CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
        return CIContext(eaglContext: EAGLContext(api: .openGLES2))
    }()
//    lazy var context: EAGLContext = {
//        return EAGLContext(api: .openGLES2)
//
//    }()
    
    func traverseFilterAttributes(filterName: String) -> [String] {
        guard let filter = CIFilter(name: filterName) else { return [] }
        var attributes = [String]()
        for attribute in filter.attributes.keys {
            attributes.append(attribute)
        }
        return attributes
    }
    
    
    
    func setAttributeValue(filterName: String) {
        guard let filter = CIFilter(name: filterName) else { return }
        var parameters = [String : Any]()
        for attribute in filter.attributes.keys {
            if attribute == kCIInputImageKey {
                
            }
        }
    }
    
    func commenFilter(name: String, parameter: [String : Any]?) -> CIImage? {
        guard let filter = CIFilter(name: name, withInputParameters: parameter) else { return nil }
        for attribute in filter.attributes.keys {
//            print(attribute)
        }
        return filter.outputImage
    }
    
    
    func oldFilmEffect(inputImage: CIImage) -> CIImage {
        //        let inputImage = CIImage(image: UIImage(named: "IMG_1108.jpg")!)
        // 1.创建CISepiaTone滤镜
        let sepiaToneFilter = CIFilter(name: "CISepiaTone")!
        sepiaToneFilter.setValue(inputImage, forKey: kCIInputImageKey)
        sepiaToneFilter.setValue(1, forKey: kCIInputIntensityKey)
        // 2.创建白班图滤镜
        let whiteSpecksFilter = CIFilter(name: "CIColorMatrix")!
        whiteSpecksFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: inputImage.extent), forKey: kCIInputImageKey)
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        // 3.把CISepiaTone滤镜和白班图滤镜以源覆盖(source over)的方式先组合起来
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
        sourceOverCompositingFilter.setValue(whiteSpecksFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter.setValue(sepiaToneFilter.outputImage, forKey: kCIInputImageKey)
        // ---------上面算是完成了一半
        // 4.用CIAffineTransform滤镜先对随机噪点图进行处理
        let affineTransformFilter = CIFilter(name: "CIAffineTransform")!
        affineTransformFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: inputImage.extent), forKey: kCIInputImageKey)
        affineTransformFilter.setValue(CGAffineTransform.init(scaleX: 1.5, y: 25), forKey: kCIInputTransformKey)
        // 5.创建蓝绿色磨砂图滤镜
        let darkScratchesFilter = CIFilter(name: "CIColorMatrix")!
        darkScratchesFilter.setValue(affineTransformFilter.outputImage, forKey: kCIInputImageKey)
        darkScratchesFilter.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        // 6.用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
        let minimumComponentFilter = CIFilter(name: "CIMinimumComponent")!
        minimumComponentFilter.setValue(darkScratchesFilter.outputImage, forKey: kCIInputImageKey)
        // ---------上面算是基本完成了
        // 7.最终组合在一起
        let multiplyCompositingFilter = CIFilter(name: "CIMultiplyCompositing")!
        multiplyCompositingFilter.setValue(minimumComponentFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        multiplyCompositingFilter.setValue(sourceOverCompositingFilter.outputImage, forKey: kCIInputImageKey)
        // 8.最后输出
        let outputImage = multiplyCompositingFilter.outputImage!
        //        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        
        return outputImage
    }
    
}
