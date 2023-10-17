//
//  Bundle+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2023/7/21.
//

import Foundation

extension Bundle {
    static var gk_bundle: Bundle? {
        normalModule ?? spmModule
    }
    
    private static var normalModule: Bundle? = {
        let bundleName = "GKNavigationBarSwift"

        var candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: GKNavigationBarConfigure.self).resourceURL,
            
            // For command-line tools.
            Bundle.main.bundleURL,
        ]
        
        #if SWIFT_PACKAGE
            // For SWIFT_PACKAGE.
            candidates.append(Bundle.module.bundleURL)
        #endif

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
    
    private static var spmModule: Bundle? = {
        let bundleName = "GKNavigationBarSwift_GKNavigationBarSwift"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: GKNavigationBarConfigure.self).resourceURL,
            
            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
}
