//
//  ImagePlayer.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class ImagePlayer {
    
    let image : UIImage
    
    // pixel 하나 고를 때 마다 표현할 UI
    var pickedSingleColor : ( (UIColor, _ x : Int, _ y : Int )  -> Void )?
    // 동작이 끝났을 때 표현할 UI
    var completionHandler: ( (Void) -> Void )?
    
    var timer : Timer?
    

    /// Toto : Customizable
    struct Option {
        var bpm : TimeInterval = 0
        var rhythm : Int? = nil
        var noteCount : Int = 0
        var playMode : PlayMode = .random
        
        enum PlayMode : String{
            case random
            case verticalScanBar
            case horizontalScanBar
        }
    }
    var option : ImagePlayer.Option
    
    
    enum PlayerStatus: String {
        case playing
        case pause
        case stop
    }
    var status : ImagePlayer.PlayerStatus = .stop
    
    init(source image: UIImage, option: ImagePlayer.Option) {
        self.image = image
        self.option = option
        
        self.pixelData = image.cgImage?.dataProvider?.data
        self.data = CFDataGetBytePtr(self.pixelData)
        
        self.prepare()
        
    }
    
    
    /*
     step1. Image 에서 픽셀location 가져오기 x
     step2. pixel을 색 정보 가져오기
     step3. 얻어온 색정보로 소리 재생
     
     step4 현란하게 재생...
     */
    
    var i = 0
    
    var pixelLocations : [Int] = []
    let pixelData : CFData?
    let data : UnsafePointer<UInt8>
    
    // 새로운 음악을 만들자
    public func prepare() {

        self.preparePixel()
        
        //timer setup
        // 1 비트를 4박자로 쪼갬
        let interval = TimeInterval(  (60 / self.option.bpm) / 4 )
        print("interval : \(interval)" )
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
    }
    
    public func play() {
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
        self.status = .playing
    }
    
    public func stop() {
        ToneController.sharedInstance().stop()
        // timer stop
        self.timer?.invalidate()
        self.prepare()
        self.status = .stop
        
        if let completionHandler = completionHandler {
            completionHandler()
        }
    }
    
    public func resume() {
        // 1 비트를 4박자로 쪼갬
        let interval = TimeInterval(  (60 / self.option.bpm) / 4 )
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(self.performImage), userInfo: nil, repeats: true)
        play()
    }
    
    public func pause() {
        ToneController.sharedInstance().stop()
        self.timer?.invalidate()
        self.status = .pause
    }
    
    
    @objc public func performImage() {
        
        if self.pixelLocations.isEmpty {
            print("ImagePlayer.performImage() : pixels empty")
            self.stop()
            return
        }
        let color = getSingleColor()
        ToneController.sharedInstance().play(color: color)
        
    }
    
    /// step1
    public func preparePixel() {

        switch self.option.playMode {
        case .random:
            
            let lastPixelLocation = Int(self.image.size.width) * Int(self.image.size.height)
            
            // lastPixelLocation 이 2^32승을 넘어 가면 gg
            // 즉, 이미지 크기가 2^32 보다 크면 안된다...
            // 2^16 = 65,536
            for _ in 0 ..< self.option.noteCount {
                let rand = arc4random_uniform(UInt32(lastPixelLocation))
                self.pixelLocations.append( Int(rand) )
            }
            
        case .horizontalScanBar:
            print()
        case .verticalScanBar :
            print()
        }
        
    }
    
    /// step2
    // pixelLocations 에서 pixel 하나 꺼내와서 `색`으로 바꿈!
    public func getSingleColor() -> UIColor{
        
        var color = UIColor.cyan
        
        switch self.option.playMode {
            case .random:
            let pixelLocation = pixelLocations.removeFirst() * 4
            
            // get color
            let r = CGFloat(data[pixelLocation]) / CGFloat(255.0)
            let g = CGFloat(data[pixelLocation+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelLocation+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelLocation+3]) / CGFloat(255.0)
            
            color = UIColor(red: r, green: g, blue: b, alpha: a)
            
            let y = (pixelLocation / 4) / Int(self.image.size.width)
            let x = (pixelLocation / 4) % Int(self.image.size.width)
            
            if let pickedSingleColor = pickedSingleColor {
                pickedSingleColor(color, x, y )
            }
           
        case .horizontalScanBar:
            color = UIColor.brown
        case .verticalScanBar :
            color = UIColor.brown
        }
        
        return color
    }
    
}
