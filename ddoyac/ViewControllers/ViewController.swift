// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import MLKit
class ViewController: UIViewController {

  // MARK: Storyboards Connections
  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var overlayView: OverlayView!
    
    var imagePicker: ImagePicker!
    
  @IBOutlet weak var resumeButton: UIButton!
  @IBOutlet weak var cameraUnavailableLabel: UILabel!
    @IBOutlet weak var previewImg: UIImageView!
    
    @IBOutlet weak var colorPickerImgView: UIImageView!
    
    var filterBundle  = FilterBundle()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultLabel: UILabel!
    //  @IBOutlet weak var bottomSheetStateImageView: UIImageView!
//  @IBOutlet weak var bottomSheetView: UIView!
//  @IBOutlet weak var bottomSheetViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var shapeLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    // MARK: Constants
  private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
  private let edgeOffset: CGFloat = 2.0
  private let labelOffset: CGFloat = 10.0
  private let animationDuration = 0.5
  private let collapseTransitionThreshold: CGFloat = -30.0
  private let expandTransitionThreshold: CGFloat = 30.0
  private let delayBetweenInferencesMs: Double = 200

  // MARK: Instance Variables
  private var initialBottomSpace: CGFloat = 0.0

  // Holds the results at any time
  private var result: Result?
  private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000

  // MARK: Controllers that manage functionality
  private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
  private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    @IBOutlet weak var cameraWarningView: UIView!
    
    private var inferenceViewController: InferenceViewController?
    private var isUsingFrontCamera = true
    private var lastFrame: CMSampleBuffer?
    
    
  // MARK: View Handling Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    overlayView.alpha = 0.8
    self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    searchBar.isUserInteractionEnabled = false
    searchBar.searchTextField.clearButtonMode = .never
    cameraWarningView.isHidden = true
    guard modelDataHandler != nil else {
      fatalError("Failed to load model")
    }
    cameraFeedManager.delegate = self
    overlayView.clearsContextBeforeDrawing = true
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
//    addPanGesture()
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedSearch(_:)))
//    searchBar.addGestureRecognizer(tapGesture)
   
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    changeBottomViewState()
    cameraFeedManager.checkCameraConfigurationAndStartSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    cameraFeedManager.stopSession()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
   
    @IBAction func onClickCaptureButton(_ sender: Any) {
        
//        openSearchDrung()
        openFilterView()
    }
    
  // MARK: Button Actions
  @IBAction func onClickResumeButton(_ sender: Any) {

    cameraFeedManager.resumeInterruptedSession { (complete) in

      if complete {
        self.resumeButton.isHidden = true
        self.cameraUnavailableLabel.isHidden = true
      }
      else {
        self.presentUnableToResumeSessionAlert()
      }
    }
  }

    @IBAction func onClickSearch(_ sender: Any) {
        
//        openSearchDrung()
        openFilterView()
        
    }
    @IBAction func onClickGuide(_ sender: Any) {
//        fatalError()
    }
    @IBAction func onClickSavedList(_ sender: Any) {
        presentSavedListViewConroller()
        
    }
    @IBAction func onClickCommonSearch(_ sender: Any) {
        openFilterView(withFilter: false)
    }
    @IBAction func onClickPhotoPicker(_ sender: UIButton) {
        self.imagePicker.presentPhotoLibrary()
    }
    
    private func openSearchDrung(){
        
        let navc = navigationController
        navc?.hero.isEnabled = true
        navc?.heroNavigationAnimationType = .fade
        
        
        let vc = SearchDrugViewController.create()

        vc.filterBundle = filterBundle
        if let keyword = searchBar.text {
            vc.keyword = keyword
        }
        
        navc?.pushViewController(vc, animated: true)
//        navc?.heroNavigationAnimationType
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openFilterView(withFilter:Bool = true){
        let navc = navigationController
        navc?.hero.isEnabled = true
        navc?.heroNavigationAnimationType = .fade
        
        
        let vc = FilterViewController.create()
        if withFilter {
            if let keyword = searchBar.text {
                filterBundle.keyword = keyword
            }
            vc.filterBundle = filterBundle
        }
        
        navc?.pushViewController(vc, animated: true)
    }
    
    
  func presentUnableToResumeSessionAlert() {
    let alert = UIAlertController(
      title: "Unable to Resume Session",
      message: "There was an error while attempting to resume session.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
  }
    
    @objc func tappedSearch(_ gesture: UITapGestureRecognizer) {
        
        debugPrint("tap")
//            let storyboard: UIStoryboard = UIStoryboard(name: "AskerList", bundle: nil)
//            let viewcontroller = storyboard.instantiateViewController(withIdentifier: "AskerListNavi")
//            present(viewcontroller, animated: true)
        }

  // MARK: Storyboard Segue Handlers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    if segue.identifier == "EMBED" {

      guard let tempModelDataHandler = modelDataHandler else {
        return
      }
      inferenceViewController = segue.destination as? InferenceViewController
      inferenceViewController?.wantedInputHeight = tempModelDataHandler.inputHeight
      inferenceViewController?.wantedInputWidth = tempModelDataHandler.inputWidth
      inferenceViewController?.threadCountLimit = tempModelDataHandler.threadCountLimit
      inferenceViewController?.currentThreadCount = tempModelDataHandler.threadCount
      inferenceViewController?.delegate = self

      guard let tempResult = result else {
        return
      }
      inferenceViewController?.inferenceTime = tempResult.inferenceTime

    }
  }
    
  

}

// MARK: InferenceViewControllerDelegate Methods
extension ViewController: InferenceViewControllerDelegate {

  func didChangeThreadCount(to count: Int) {
    if modelDataHandler?.threadCount == count { return }
    modelDataHandler = ModelDataHandler(
      modelFileInfo: MobileNetSSD.modelInfo,
      labelsFileInfo: MobileNetSSD.labelsInfo,
      threadCount: count
    )
  }

}

// MARK: CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {

    func runOCRModel(sampleBuffer : CMSampleBuffer, pixelBuffer: CVPixelBuffer) {
//
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//          print("Failed to get image buffer from sample buffer.")
//          return
//        }
        
        
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
//        let orientation = UIUtilities.imageOrientation()
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        recognizeTextOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        
    }
    
  func didOutput(sampleBuffer: CMSampleBuffer, pixelBuffer: CVPixelBuffer) {
    
    let currentTimeMs = Date().timeIntervalSince1970 * 1000

    guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
      return
    }

    
    
    previousInferenceTimeMs = currentTimeMs
    
    
    runModel(onPixelBuffer: pixelBuffer)
    
    runOCRModel(sampleBuffer: sampleBuffer, pixelBuffer: pixelBuffer)
    
  }

    
    private func convertedPoints(
      from points: [NSValue]?,
      width: CGFloat,
      height: CGFloat
    ) -> [NSValue]? {
        
      return points?.map {
        let cgPointValue = $0.cgPointValue
        let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
        let cgPoint = self.previewView.previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        let value = NSValue(cgPoint: cgPoint)
        return value
      }
    }
    private func updatePreviewOverlayViewWithLastFrame() {
      guard let lastFrame = lastFrame,
        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
      else {
        return
      }
      self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
    }

    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
      guard let imageBuffer = imageBuffer else {
        return
      }
      let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
      let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
      
        
//        previewOverlayView.image = image
    }
    
    
    private func removeDetectionAnnotations() {
      for annotationView in overlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }

    
  // MARK: Session Handling Alerts
  func sessionRunTimeErrorOccurred() {

    // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
    self.resumeButton.isHidden = false
  }

  func sessionWasInterrupted(canResumeManually resumeManually: Bool) {

    // Updates the UI when session is interrupted.
    if resumeManually {
      self.resumeButton.isHidden = false
    }
    else {
      self.cameraUnavailableLabel.isHidden = false
    }
    
  }

  func sessionInterruptionEnded() {

    // Updates UI once session interruption has ended.
    if !self.cameraUnavailableLabel.isHidden {
      self.cameraUnavailableLabel.isHidden = true
    }

    if !self.resumeButton.isHidden {
      self.resumeButton.isHidden = true
    }
  }

  func presentVideoConfigurationErrorAlert() {

    let alertController = UIAlertController(title: "Configuration Failed", message: "Configuration of camera has failed.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  func presentCameraPermissionsDeniedAlert() {

    let alertController = UIAlertController(title: "Camera Permissions Denied", message: "Camera permissions have been denied for this app. You can change this by going to Settings", preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in

      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)

    present(alertController, animated: true, completion: nil)

  }
    
   
  /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
   */
  @objc  func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {

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
      self.inferenceViewController?.resolution = CGSize(width: width, height: height)

      var inferenceTime: Double = 0
      if let resultInferenceTime = self.result?.inferenceTime {
        inferenceTime = resultInferenceTime
      }
      self.inferenceViewController?.inferenceTime = inferenceTime
      self.inferenceViewController?.tableView.reloadData()

      // Draws the bounding boxes and displays class names and confidence scores.
      self.drawAfterPerformingCalculations(pixelBuffer, onInferences: displayResult.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
    }
  }

  /**
   This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
   */
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
        
      let confidenceValue = Int(inference.confidence * 100.0)
      let string = "\(shapeName)  (\(confidenceValue)%)"
        shape = inference.className
      let size = string.size(usingFont: self.displayFont)

      let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)

      objectOverlays.append(objectOverlay)
    }

    if let shape = shape {
        shapeLabel.text = LabelHelper.convertShapeLabelFromOriginal(labelName: shape)
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
                    self.previewImg.image = uiimg
//                    self.previewImg.layer.cornerRadius = 8.0
//                    self.previewImg.layer.masksToBounds = true
//                    self.previewImg.clipsToBounds = true
                    
                }
            }
            
            
//            if let half = CVPixelHelper.halfSizeSquareCenterCropPixelBuffer(scaledPixelBuffer) {
                if let cgimg = scaledPixelBuffer.createImage(){
                    let color = UIImage(cgImage: cgimg).areaAverage()
                    
                    
//                    colorPickerImgView.
                    let name = DBColorNames.name(for: color)
                    filterBundle.detect_color = name
//                    resultLabel.text = name
//                    resultLabel.textColor = color
                    self.colorLabel.isHidden = true
                    self.colorLabel.text = name
                    
                    if let key = name, let rgb = DBColorNames.colorMap[key], let uicolor = DBColorNames.colorConvert(fromRGBFloat: rgb) {
                        
                        self.colorPickerImgView.image = uicolor.image(CGSize(width: 22, height: 22))
                        
                        self.colorPickerImgView.layer.cornerRadius = 15.0
                        self.colorPickerImgView.sizeToFit()
                    }
                }
//            }
            
            
        }
  
           
        
        
    }
    // Hands off drawing to the OverlayView
    self.draw(objectOverlays: objectOverlays)

  }

  /** Calls methods to update overlay view with detected bounding boxes and class names.
   */
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
          let points = strongSelf.convertedPoints(
            from: block.cornerPoints, width: width, height: height)
            
//          UIUtilities.addShape(
//            withPoints: points,
//            to: strongSelf.overlayView,
//            color: UIColor.purple
//          )

          // Lines.
          for line in block.lines {
            let points = strongSelf.convertedPoints(
              from: line.cornerPoints, width: width, height: height)
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
                
                let transform = CGAffineTransform(scaleX: self.previewView.bounds.size.width / width, y: self.previewView.bounds.size.height / height)
                let moveY = CGAffineTransform(translationX: 0, y: -70)
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
                searchBar.text = resultText
                
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
}
extension ViewController: DrawerPresentationControllerDelegate {
    func drawerMovedTo(position: DraweSnapPoint) {
        
    }
    
   
    
    func presentSavedListViewConroller() {
        let viewController = SavedListViewController.create()
        viewController.delegate = self
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            self.present(viewController, animated: true)
        }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController =  DrawerPresentationController(presentedViewController: presented, presenting: presenting, blurEffectStyle: .regular)
        presentationController.cornerRadius = 20
        presentationController.roundedCorners = [.topLeft, .topRight]
        presentationController.bounce = false
        presentationController.topGap = 200
        
        return presentationController
    }
}
extension ViewController: SavedListDelegate{
    func selectedList(id:Int, title:String){
        let vc = DrugsInSavedListViewController.create()
        vc.id = id
        vc._title = title
        
//        present(vc, animated: true, completion: nil)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
//        self.imageView.image = image
        
        
        let svc = StaticImageViewController.create()
        svc.pickImage = image
        
        
        navigationController?.pushViewController(svc, animated: true)
    }
}
