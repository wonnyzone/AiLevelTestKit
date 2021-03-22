//
//  ALTNavigationController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/01/27.
//

import UIKit

class ALTNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return self.topViewController?.supportedInterfaceOrientations ?? (UIDevice.current.userInterfaceIdiom == .pad ? .landscapeRight : .portrait)
        }
    }

    override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
}
