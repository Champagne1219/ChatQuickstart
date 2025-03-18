//
//  CustomUIButton.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit
import Foundation

public class CustomUIButton: UIButton {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.insetBy(dx: -10, dy: -10)
        return extendedBounds.contains(point)
    }
}
