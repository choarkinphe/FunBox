//
//  UIImage+Fun.swift
//  FunBox
//
//  Created by choarkinphe on 2020/5/11.
//

import UIKit

extension UIImage: FunNamespaceWrappable {}

public extension FunNamespaceWrapper where T: UIImage {
    static var launchImage: UIImage? {
        let viewSize = UIScreen.main.bounds.size
        var viewOrientation = "Portrait"
        let orientation = UIApplication.shared.statusBarOrientation
        if [.landscapeRight,.landscapeLeft].contains(orientation) {
            viewOrientation = "Landscape"
        }
        
        if let images = Bundle.main.infoDictionary?["UILaunchImages"] as? [Any] {
            print(images)
            for element in images {
                if let dict = element as? [String: String] {
                    
                    let imageSize = CGSize.init(string: dict["UILaunchImageSize"])
                    
                    if viewSize.equalTo(imageSize), viewOrientation == dict["UILaunchImageOrientation"] {
                        if let imageName = dict["UILaunchImageName"] {
                            return UIImage(named: imageName)
                        }
                        
                    }
                }
                
            }
            
        } else {
            
            
        }
        
        return nil
    }
}



