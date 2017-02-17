//
//  UIColor.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 16..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

extension UIColor {
    
    // frequency = 110 * pow(2, (saturation*2)) * pow(2, hue)
    func color2sound() -> Double{
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        
        let result = self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        if result {
            let hue = Double(hue)
            let saturation = Double(saturation)
            let frequency = 110 * pow(2,saturation*2) * pow(2, hue)
            
            let formattedFrequency = String(format: "%.2f", frequency)
            print("frequency : \(formattedFrequency)Hz")
            return frequency
            
        }
        // 기본음 A (라)
        return 440
    }
    
    // frequency = 220 *  pow(2, hue*2)
    func color2soundSimple() -> Double {
        var hue: CGFloat = 0
        var brightness : CGFloat = 0
        let result = self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: nil)
        
        if result {
            let hue = Double(hue)
            let frequency = 220 *  pow(2, hue*2)
            let formattedFrequency = String(format: "%.2f", frequency)
            print("frequency : \(formattedFrequency)Hz")
            print("brightness : \(brightness)")
            return frequency
            
        }
        // 기본음 A (라)
        return 440
    }
    
    
    // midi = 69 + 12 * { log( freq / 440) / log(2) }
    func color2midiNumberSimple() -> MIDINoteNumber {
        
        return MIDINoteNumber ( 69 + ( 12 * log2( self.color2soundSimple() / 440) ) )
        
    }
}