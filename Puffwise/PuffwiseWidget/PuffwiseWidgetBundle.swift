//
//  PuffwiseWidgetBundle.swift
//  PuffwiseWidget
//
//  Created by Joseph Barkie on 3/12/26.
//

import WidgetKit
import SwiftUI

@main
struct PuffwiseWidgetBundle: WidgetBundle {
    var body: some Widget {
        PuffwiseWidget()
        PuffwiseWidgetControl()
        PuffwiseWidgetLiveActivity()
    }
}
