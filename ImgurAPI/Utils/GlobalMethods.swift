//
//  GlobalMethods.swift
//  NextDriveAppSDK_iOS
//
//  Created by Shih Chi Wei on 2022/5/21.
//

import UIKit

enum QueueDispatch {
    case sync
    case async
}

func ensureInMainQueue(dispatch: QueueDispatch = .async, _ block: @escaping () -> Void) {
    if Thread.isMainThread { block() } else {
        if dispatch == .async {
            DispatchQueue.main.async { block() }
        } else {
            DispatchQueue.main.sync { block() }
        }
    }
}
