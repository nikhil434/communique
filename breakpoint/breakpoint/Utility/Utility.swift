//
//  Utility.swift
//  
//
//  Created by vineeth on 6/14/18.
//  Copyright © 2018 vineeth. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    static var loadingIndicatorView: LoadingIndicator!
    
    //MARK:- Loding indicator
    class func showLoadingIndicator() {
        loadingIndicatorView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        APP_DELEGATE.window!.addSubview(loadingIndicatorView)
        loadingIndicatorView.startProgressLoading()
    }
    
    class func hideLoadingIndicator() {
        if (loadingIndicatorView != nil) {
            loadingIndicatorView.stopProgressLoading()
            loadingIndicatorView.removeFromSuperview()
            loadingIndicatorView = nil
        }
    }
}
