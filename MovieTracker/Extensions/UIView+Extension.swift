//
//  UIImageView+Gradient.swift
//  MovieTracker
//
//  Created by Elliot Barer on 6/8/18.
//  Copyright © 2018 ebarer. All rights reserved.
//

import UIKit

extension UIView {
    func addGradient(colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addGradientView(colors: [UIColor], locations: [NSNumber] = [0.0, 1.0],
                         view: UIView? = nil, frame: CGRect? = nil)
    {
        let gradientView = PassThroughView()
        
        if let subview = view, let frame = frame {
            gradientView.frame = frame
            gradientView.addGradient(colors: colors, locations: locations)
            self.insertSubview(gradientView, aboveSubview: subview)
        } else {
            gradientView.frame = self.frame
            gradientView.addGradient(colors: colors, locations: locations)
            self.insertSubview(gradientView, at: 0)
        }
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 350, height: 350)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        // Find average color
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [CIContextOption.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: CIFormat.RGBA8,
                       colorSpace: nil)
        
        let rgbColor = UIColor(red: CGFloat(bitmap[0]) / 255,
                               green: CGFloat(bitmap[1]) / 255,
                               blue: CGFloat(bitmap[2]) / 255,
                               alpha: 255)
        
        var hue = CGFloat(), sat = CGFloat()
        rgbColor.getHue(&hue, saturation: &sat, brightness: nil, alpha: nil)
        
        // If hue/sat are 0.0, return default color
        if hue == 0.0 && sat == 0.0 {
            return UIColor.accent
        }
        
        // Generate custom color using hue of average color,
        // with stronger brightness and saturation
        return UIColor(hue: hue, saturation: max(0.5, sat), brightness: 1, alpha: 1)
    }
}

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
