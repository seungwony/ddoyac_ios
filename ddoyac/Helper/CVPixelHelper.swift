//
//  CVPixelHelper.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/04/30.
//

import Foundation
import Accelerate
import AVFoundation
import CoreImage
import UIKit

class CVPixelHelper {
    /**
     Creates a RGB pixel buffer of the specified width and height.
     */
    
    class func createPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, width, height,
                                         kCVPixelFormatType_32BGRA, nil,
                                         &pixelBuffer)
        if status != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status)
            return nil
        }
        return pixelBuffer
    }
    
  
    /**
     First crops the pixel buffer, then resizes it.
     */
    class func resizePixelBuffer(_ srcPixelBuffer: CVPixelBuffer,
                                  cropX: Int,
                                  cropY: Int,
                                  cropWidth: Int,
                                  cropHeight: Int,
                                  scaleWidth: Int,
                                  scaleHeight: Int) -> CVPixelBuffer? {
        
        CVPixelBufferLockBaseAddress(srcPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer) else {
            print("Error: could not get pixel buffer base address")
            return nil
        }
        let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
        let offset = cropY*srcBytesPerRow + cropX*4
        var srcBuffer = vImage_Buffer(data: srcData.advanced(by: offset),
                                      height: vImagePixelCount(cropHeight),
                                      width: vImagePixelCount(cropWidth),
                                      rowBytes: srcBytesPerRow)
        
        let destBytesPerRow = scaleWidth*4
        guard let destData = malloc(scaleHeight*destBytesPerRow) else {
            print("Error: out of memory")
            return nil
        }
        var destBuffer = vImage_Buffer(data: destData,
                                       height: vImagePixelCount(scaleHeight),
                                       width: vImagePixelCount(scaleWidth),
                                       rowBytes: destBytesPerRow)
        
        let error = vImageScale_ARGB8888(&srcBuffer, &destBuffer, nil, vImage_Flags(0))
        CVPixelBufferUnlockBaseAddress(srcPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        if error != kvImageNoError {
            print("Error:", error)
            free(destData)
            return nil
        }
        
        let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
            if let ptr = ptr {
                free(UnsafeMutableRawPointer(mutating: ptr))
            }
        }
        
        let pixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer)
        var dstPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreateWithBytes(nil, scaleWidth, scaleHeight,
                                                  pixelFormat, destData,
                                                  destBytesPerRow, releaseCallback,
                                                  nil, nil, &dstPixelBuffer)
        if status != kCVReturnSuccess {
            print("Error: could not create new pixel buffer")
            free(destData)
            return nil
        }
        return dstPixelBuffer
    }

    /**
     Resizes a CVPixelBuffer to a new width and height.
     */
    class func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                                  width: Int, height: Int) -> CVPixelBuffer? {
        return resizePixelBuffer(pixelBuffer, cropX: 0, cropY: 0,
                                 cropWidth: CVPixelBufferGetWidth(pixelBuffer),
                                 cropHeight: CVPixelBufferGetHeight(pixelBuffer),
                                 scaleWidth: width, scaleHeight: height)
    }



    class func resizeSquareCenterCropPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        
        let refWidth = CVPixelBufferGetWidth(pixelBuffer)
        let refHeight = CVPixelBufferGetHeight(pixelBuffer)
        
        
        var width = refWidth
        var height = refHeight
        
        if width > height {
            width = height
        }else{
            height = width
        }
        
        
        let x = (refWidth / 2) - (width / 2)
        let y = (refHeight / 2) - (height / 2)
        
        
        
        return CVPixelHelper.resizePixelBuffer(pixelBuffer, cropX: x, cropY: y,
                                 cropWidth: width,
                                 cropHeight: height,
                                 scaleWidth: width, scaleHeight: height)
    }


    class func resizeSquareCenterCropPixelBuffer(_ pixelBuffer: CVPixelBuffer,
                                  target_width: Int, target_height: Int) -> CVPixelBuffer? {
        
        
        let refWidth = CVPixelBufferGetWidth(pixelBuffer)
        let refHeight = CVPixelBufferGetHeight(pixelBuffer)
        
        
        var width = refWidth
        var height = refHeight
        
        if width > height {
            width = height
        }else{
            height = width
        }
        
        
        let x = (refWidth / 2) - (width / 2)
        let y = (refHeight / 2) - (height / 2)
        
        return resizePixelBuffer(pixelBuffer, cropX: x, cropY: y,
                                 cropWidth: width,
                                 cropHeight: height,
                                 scaleWidth: target_width, scaleHeight: target_height)
    }


    /**
     Resizes a CVPixelBuffer to a new width and height.
     */
    class func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                                  width: Int, height: Int,
                                  output: CVPixelBuffer, context: CIContext) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let sx = CGFloat(width) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let sy = CGFloat(height) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        let scaledImage = ciImage.transformed(by: scaleTransform)
        context.render(scaledImage, to: output)
    }
    
    
    
    class func resizeTargetSizePixelBuffer(_ pixelBuffer: CVPixelBuffer,
                                            x:Int, y:Int, target_width: Int, target_height: Int) -> CVPixelBuffer? {
        
        
        
        return resizePixelBuffer(pixelBuffer, cropX: x, cropY: y,
                                 cropWidth: target_width,
                                 cropHeight: target_height,
                                 scaleWidth: target_width, scaleHeight: target_height)
    }
    
    class func halfSizeSquareCenterCropPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        
        let refWidth = CVPixelBufferGetWidth(pixelBuffer)
        let refHeight = CVPixelBufferGetHeight(pixelBuffer)
        
        
        var width = refWidth / 2
        var height = refHeight / 2
        
        if width > height {
            width = height
        }else{
            height = width
        }
        
        
        let x = (refWidth / 2) - (width / 2)
        let y = (refHeight / 2) - (height / 2)
        
        
        
        return resizePixelBuffer(pixelBuffer, cropX: x, cropY: y,
                                 cropWidth: width,
                                 cropHeight: height,
                                 scaleWidth: width, scaleHeight: height)
    }



    class func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
        
        //    let newImage = resize(image: image, newSize: CGSize(width: 224/3.0, height: 224/3.0))
        
        let ciimage = CIImage(image: image)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        let width = cgimage!.width
        let height = cgimage!.height
        
        var pxbuffer: CVPixelBuffer?
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!)
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        //    context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        
        
        
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer!
        
    }

}
