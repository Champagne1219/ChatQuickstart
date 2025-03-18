//
//  LiveActivitiesWidgetBundle.swift
//  LiveActivitiesWidget
//
//  Created by 谢强彬
//

import WidgetKit
import SwiftUI

///@main
struct LiveActivitiesWidgetBundle: WidgetBundle {
    var body: some Widget {
        /// LiveActivitiesWidget()
        LiveActivitiesWidgetControl()
        LiveActivitiesWidgetLiveActivity()
    }
}
