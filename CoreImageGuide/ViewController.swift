//
//  ViewController.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 20/09/2017.
//  Copyright © 2017 Gregory Qian. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputImage = CIImage(image: UIImage(named: "IMG_1158.jpg")!)
        

//        imageView.image = UIImage(ciImage: filter!.outputImage!)
        imageView.contentMode = .scaleAspectFit
//        whiteVignette()
        oldFilmEffect()
    
    }
    
    func oldFilmEffect() {
        let inputImage = CIImage(image: UIImage(named: "IMG_1108.jpg")!)
        // 1.创建CISepiaTone滤镜
        let sepiaToneFilter = CIFilter(name: "CISepiaTone")!
        sepiaToneFilter.setValue(inputImage, forKey: kCIInputImageKey)
        sepiaToneFilter.setValue(1, forKey: kCIInputIntensityKey)
        // 2.创建白班图滤镜
        let whiteSpecksFilter = CIFilter(name: "CIColorMatrix")!
        whiteSpecksFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: (inputImage?.extent)!), forKey: kCIInputImageKey)
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
        affineTransformFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: (inputImage?.extent)!), forKey: kCIInputImageKey)
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
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        imageView.image = UIImage(cgImage: cgImage!)
    }
    
    func oldFilmFilterRecipe() {
        let inputImage = CIImage(image: UIImage(named: "IMG_1108.jpg")!)
        let sepiaFilter = CIFilter(name: "CISepiaTone", withInputParameters: [kCIInputImageKey : inputImage,
                                                                              kCIInputIntensityKey : 1.0])
        let randomFilter = CIFilter(name: "CIRandomGenerator")
        let whiteMatrixFilter = CIFilter(name: "CIColorMatrix", withInputParameters: [kCIInputImageKey : randomFilter?.outputImage,
                                                                                      "inputRVector" : CIVector(x: 0, y: 1, z: 0, w: 0),
                                                                                      "inputGVector" : CIVector(x: 0, y: 1, z: 0, w: 0),
                                                                                      "inputBVector" : CIVector(x: 0, y: 1, z: 0, w: 0),
                                                                                      "inputBiasVector" : CIVector(x: 0, y: 0, z: 0, w: 0)])
        let whiteSpeckFilter = CIFilter(name: "CISourceOverCompositing", withInputParameters: [kCIInputImageKey : whiteMatrixFilter?.outputImage,
                                                                                               kCIInputBackgroundImageKey : sepiaFilter?.outputImage])
        
        let trans = CGAffineTransform.init(scaleX: 1.5, y: 25)
        let affineTransformFilter = CIFilter(name: "CIAffineTransform", withInputParameters: [kCIInputImageKey : randomFilter?.outputImage,
                                                                                        kCIInputTransformKey : trans])
        let darkScratchesFilter = CIFilter(name: "CIColorMatrix")!
        darkScratchesFilter.setValue(affineTransformFilter?.outputImage, forKey: kCIInputImageKey)
        darkScratchesFilter.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        
        let minimumComponentFilter = CIFilter(name: "CIMinimumComponent")!
        minimumComponentFilter.setValue(darkScratchesFilter.outputImage, forKey: kCIInputImageKey)
        
        let multiplyCompositingFilter = CIFilter(name: "CIMultiplyCompositing")!
        multiplyCompositingFilter.setValue(minimumComponentFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        multiplyCompositingFilter.setValue(whiteMatrixFilter?.outputImage, forKey: kCIInputImageKey)
        
        imageView.image = UIImage(ciImage: multiplyCompositingFilter.outputImage!)
        
    }
    
    func tiltShiftFilterRecipe() {
        let h = self.view.bounds.height
        let inputImage = CIImage(image: UIImage(named: "BABYMETAL.jpg")!)
        let blurFilter = CIFilter(name: "CIGaussianBlur", withInputParameters: [kCIInputImageKey : inputImage!,
                                                                              kCIInputRadiusKey : 10.0])
        let downLinearGradientFilter = CIFilter(name: "CILinearGradient", withInputParameters: ["inputPoint0" : CIVector(x: 0, y: 0.75 * h),
                                                                                            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                                                                            "inputPoint1" : CIVector(x: 0, y: 0.5 * h),
                                                                                            "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)])
        let upLinearGradientFilter = CIFilter(name: "CILinearGradient", withInputParameters: ["inputPoint0" : CIVector(x: 0, y: 0.25 * h),
                                                                                               "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                                                                               "inputPoint1" : CIVector(x: 0, y: 0.5 * h),
                                                                                               "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)])
        
        let compositingFilter = CIFilter(name: "CIAdditionCompositing", withInputParameters: [kCIInputImageKey : downLinearGradientFilter?.outputImage! as Any,
                                                                                              kCIInputBackgroundImageKey: upLinearGradientFilter?.outputImage! as Any])
        let maskFilter = CIFilter(name: "CIBlendWithMask", withInputParameters: [kCIInputImageKey : blurFilter?.outputImage! as Any,
                                                                                 kCIInputBackgroundImageKey : inputImage!,
                                                                                 kCIInputMaskImageKey : compositingFilter?.outputImage! as Any])
        imageView.image = UIImage(ciImage: (maskFilter?.outputImage)!)
        
    }
    
    func whiteVignette() {
        let inputImage = CIImage(image: UIImage(named: "IMG_1158.jpg")!)
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: nil)
        let faces = detector?.features(in: inputImage!)
        let face = faces?.first
        let xCenter = (face?.bounds.origin.x)! + (face?.bounds.size.width)!/2.0
        let yCenter = (face?.bounds.origin.y)! + (face?.bounds.size.height)!/2.0
        let center = CIVector(x: xCenter, y: yCenter)
        print(center)
        
        let radialGradient = CIFilter(name: "CIRadialGradient",
                                      withInputParameters: [
                                        "inputRadius0" : 1000,
                                        "inputRadius1" : 100,
                                        "inputColor0" : CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                        "inputColor1" : CIColor(red: 1, green: 1, blue: 1, alpha: 0.1),
                                        kCIInputCenterKey : center
            ])
        let radialGradientOutputImage = radialGradient!.outputImage
        
        let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: [kCIInputImageKey: radialGradientOutputImage!,
                                                                                     kCIInputBackgroundImageKey: inputImage!
            ])
        let outputImage = filter!.outputImage!
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        imageView.image = UIImage(cgImage: cgImage!)
    }
    
    func applyFilterChain(to image: CIImage) -> CIImage {
        // The CIPhotoEffectInstant filter takes only an input image
        let colorFilter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
            [kCIInputImageKey: image])!
        
        // Pass the result of the color filter into the Bloom filter
        // and set its parameters for a glowy effect.
        let bloomImage = colorFilter.outputImage!.applyingFilter("CIBloom",
                                                                 withInputParameters: [
                                                                    kCIInputRadiusKey: 10.0,
                                                                    kCIInputIntensityKey: 1.0
            ])
        
        // imageByCroppingToRect is a convenience method for
        // creating the CICrop filter and accessing its outputImage.
        let cropRect = CGRect(x: 350, y: 350, width: 150, height: 150)
        let croppedImage = bloomImage.cropping(to: cropRect)
        
        return colorFilter.outputImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

