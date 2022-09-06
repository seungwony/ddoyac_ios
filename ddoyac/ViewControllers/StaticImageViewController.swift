//
//  StaticImageViewController.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/21.
//

import UIKit
import MLKit
class StaticImageViewController: UIViewController {
    @IBOutlet weak var pickImg: UIImageView!
    @IBOutlet weak var targetImg: UIImageView!
    @IBOutlet weak var shapeLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var ocrLabel: UILabel!
    
    @IBOutlet weak var overlayView: OverlayView!
    var pickImage:UIImage?
    
    var filterBundle  = FilterBundle()
    private var result: Result?
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private let animationDuration = 0.5
    private let collapseTransitionThreshold: CGFloat = -30.0
    private let expandTransitionThreshold: CGFloat = 30.0
    private let delayBetweenInferencesMs: Double = 200
    private var modelDataHandler: ModelDataHandler? =
      ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.backgroundColor = .clear
        overlayView.alpha = 0.8
        // Do any additional setup after loading the view.
//        overlayView.clearsContextBeforeDrawing = true
        if let img = pickImage {
            
            DispatchQueue.global().async {
                if let cvpixelBuffer =  self.buffer(from: img) {
                    self.runModel(onPixelBuffer: cvpixelBuffer)
    //
    //
                    
                    
                    let imageWidth = CGFloat(CVPixelBufferGetWidth(cvpixelBuffer))
                    let imageHeight = CGFloat(CVPixelBufferGetHeight(cvpixelBuffer))
                    let visionImage = VisionImage(image: img)
                    self.recognizeTextOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.pickImg.image = img
                        self.pickImg.setNeedsDisplay()
                        
                        
                    }
                }
            }
            
            
           
            
        }
    }

    class func create() -> StaticImageViewController {
          let staticImageViewController = StaticImageViewController(nibName: "StaticImageViewController", bundle: nil)
        
          return staticImageViewController
      }
    
    
    @IBAction func onClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickResult(_ sender: Any) {
        
        openFilterView()
    }
    @IBAction func onClickFilter(_ sender: Any) {
        openFilterView()
    }
    
    private func openFilterView(withFilter:Bool = true){
        let navc = navigationController
        navc?.hero.isEnabled = true
        navc?.heroNavigationAnimationType = .fade
        
        
        let vc = FilterViewController.create()
        if withFilter {
            
            filterBundle.keyword = filterBundle.keyword
            vc.filterBundle = filterBundle
        }
        
        navc?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {

      // Run the live camera pixelBuffer through tensorFlow to get the result

  //    let currentTimeMs = Date().timeIntervalSince1970 * 1000
  //
  //    guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
  //      return
  //    }
  //
  //
  //
  //    previousInferenceTimeMs = currentTimeMs
      result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)

      guard let displayResult = result else {
        return
      }

      let width = CVPixelBufferGetWidth(pixelBuffer)
      let height = CVPixelBufferGetHeight(pixelBuffer)

      DispatchQueue.main.async {

        // Display results by handing off to the InferenceViewController
        

        var inferenceTime: Double = 0
        if let resultInferenceTime = self.result?.inferenceTime {
          inferenceTime = resultInferenceTime
        }
        

        // Draws the bounding boxes and displays class names and confidence scores.
        self.drawAfterPerformingCalculations(pixelBuffer, onInferences: displayResult.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
      }
    }
    
    func drawAfterPerformingCalculations(_ pixelBuffer: CVPixelBuffer, onInferences inferences: [Inference], withImageSize imageSize:CGSize) {

      self.overlayView.objectOverlays = []
      self.overlayView.setNeedsDisplay()

      guard !inferences.isEmpty else {
        return
      }

      var objectOverlays: [ObjectOverlay] = []
      var refRect : CGRect? = nil
      var shape:String? = nil
      for inference in inferences {

        // Translates bounding box rect to current view.
        var convertedRect = inference.rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imageSize.width, y: self.overlayView.bounds.size.height / imageSize.height))
         
          let scaleX = imageSize.width / imageSize.width
          let scaleY = imageSize.width / imageSize.height
          refRect = inference.rect.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        if convertedRect.origin.x < 0 {
          convertedRect.origin.x = self.edgeOffset
        }

        if convertedRect.origin.y < 0 {
          convertedRect.origin.y = self.edgeOffset
        }

        if convertedRect.maxY > self.overlayView.bounds.maxY {
          convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
        }

        if convertedRect.maxX > self.overlayView.bounds.maxX {
          convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
        }

          let shapeName = LabelHelper.convertShapeLabelFromOriginal(labelName: inference.className)
        self.shapeLabel.text = "모양 : \(shapeName)"
          
        let confidenceValue = Int(inference.confidence * 100.0)
        let string = "\(shapeName)  (\(confidenceValue)%)"
          shape = inference.className
        let size = string.size(usingFont: self.displayFont)

        let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)

        objectOverlays.append(objectOverlay)
      }

      if let shape = shape {
        let shapeStr = LabelHelper.convertShapeLabelFromOriginal(labelName: shape)
//          shapeLabel.text = LabelHelper.convertShapeLabelFromOriginal(labelName: shape)
          filterBundle.shape = shape
      }
      
      if let rect = refRect{
  //            rect.minX
  //            guard let tempModelDataHandler = self.modelDataHandler else {
  //              return
  //            }
          guard let scaledCenterCropPixelBuffer = CVPixelHelper.resizeSquareCenterCropPixelBuffer(pixelBuffer) else {
              return
          }
          
  //            print(rect.debugDescription)
          
          if let scaledPixelBuffer = CVPixelHelper.resizeTargetSizePixelBuffer(scaledCenterCropPixelBuffer, x: Int(rect.origin.x), y: Int(rect.origin.y), target_width: Int(rect.width), target_height: Int(rect.height)) {
              
              if let cgimg = scaledPixelBuffer.createImage(){
                  let uiimg = UIImage(cgImage: cgimg)
  //                print(uiimg.debugDescription)
                  DispatchQueue.main.async {
                      self.targetImg.image = uiimg

                      
                  }
              }
              
              
              if let half = CVPixelHelper.halfSizeSquareCenterCropPixelBuffer(scaledPixelBuffer) {
                  if let cgimg = scaledPixelBuffer.createImage(){
                      let color = UIImage(cgImage: cgimg).areaAverage()
                      
                      
                      let name = DBColorNames.name(for: color)
                      filterBundle.detect_color = name

                    self.colorLabel.text = "색상 : \(name!))"
                  }
              }
              
              
          }
    
             
          
          
      }
      // Hands off drawing to the OverlayView
      self.draw(objectOverlays: objectOverlays)

    }

    func draw(objectOverlays: [ObjectOverlay]) {

      self.overlayView.objectOverlays = objectOverlays
      self.overlayView.setNeedsDisplay()
    }
    
    func drawOCR(objectOverlays: [ObjectOverlay]) {

      self.overlayView.ocrOverlays = objectOverlays
      self.overlayView.setNeedsDisplay()
    }
    
    private func recognizeTextOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
      var recognizedText: Text
      do {
        recognizedText = try TextRecognizer.textRecognizer().results(in: image)
      } catch let error {
        print("Failed to recognize text with error: \(error.localizedDescription).")
        return
      }
        
        self.overlayView.ocrOverlays = []
        
        var objectOverlays: [ObjectOverlay] = []

      weak var weakSelf = self
      DispatchQueue.main.sync {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
//        strongSelf.updatePreviewOverlayViewWithLastFrame()
//        strongSelf.removeDetectionAnnotations()
        
//        self.overlayView.setNeedsDisplay()
        // Blocks.
        for block in recognizedText.blocks {
//          let points = strongSelf.convertedPoints(
//            from: block.cornerPoints, width: width, height: height)
            
//          UIUtilities.addShape(
//            withPoints: points,
//            to: strongSelf.overlayView,
//            color: UIColor.purple
//          )

          // Lines.
          for line in block.lines {
//            let points = strongSelf.convertedPoints(
//              from: line.cornerPoints, width: width, height: height)
//            UIUtilities.addShape(
//              withPoints: points,
//              to: strongSelf.overlayView,
//              color: UIColor.orange
//            )

            // Elements.
//            let width = overlayView.bounds.width
//            let height = overlayView.bounds.height
            
            
            for element in line.elements {
              let normalizedRect = CGRect(
                x: element.frame.origin.x / width,
                y: element.frame.origin.y / height,
                width: element.frame.size.width / width,
                height: element.frame.size.height / height
              )
//                let convertedRect = strongSelf.previewView.previewLayer.layerRectConverted(
//                fromMetadataOutputRect: normalizedRect
//              )
                

//                var convertedRect = element.frame.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / width, y: (self.overlayView.bounds.size.height / height))
                
                let transform = CGAffineTransform(scaleX: self.pickImg.bounds.size.width / width, y: self.pickImg.bounds.size.height / height)
                let moveY = CGAffineTransform(translationX: 0, y: 0)
//                transform.translatedBy(x: 0, y: -100)
                let combine = transform.concatenating(moveY)
                var convertedRect = element.frame.applying(combine)
//                var convertedRect =  element.frame.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / width, y: self.overlayView.bounds.size.height / height)

                
                if convertedRect.origin.x < 0 {
                  convertedRect.origin.x = self.edgeOffset
                }

                if convertedRect.origin.y < 0 {
                  convertedRect.origin.y = self.edgeOffset
                }

                if convertedRect.maxY > self.overlayView.bounds.maxY {
                  convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
                }

                if convertedRect.maxX > self.overlayView.bounds.maxX {
                  convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
                }
//              UIUtilities.addRectangle(
//                convertedRect,
//                to: strongSelf.overlayView,
//                color: UIColor.green
//              )
                
              let label = UILabel(frame: convertedRect)
              label.text = element.text
              label.adjustsFontSizeToFitWidth = true
                
                
                let resultText = element.text
                self.ocrLabel.text = "문자 추출 : \(resultText)"
                
                filterBundle.keyword = resultText
                
                let size = resultText.size(usingFont: self.displayFont)
                let objectOverlay = ObjectOverlay(name: resultText, borderRect: convertedRect, nameStringSize: size, color: UIColor.white, font: self.displayFont)
                
                objectOverlays.append(objectOverlay)
//              strongSelf.rotate(label, orientation: image.orientation)
//              strongSelf.annotationOverlayView.addSubview(label)
            }
          }
        }
        
        self.drawOCR(objectOverlays: objectOverlays)
      }
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
}
