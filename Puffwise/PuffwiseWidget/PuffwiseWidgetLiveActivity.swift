//
//  PuffwiseWidgetLiveActivity.swift
//  PuffwiseWidget
//
//  Created by Joseph Barkie on 3/12/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PuffwiseWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PuffwiseWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PuffwiseWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PuffwiseWidgetAttributes {
    fileprivate static var preview: PuffwiseWidgetAttributes {
        PuffwiseWidgetAttributes(name: "World")
    }
}

extension PuffwiseWidgetAttributes.ContentState {
    fileprivate static var smiley: PuffwiseWidgetAttributes.ContentState {
        PuffwiseWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PuffwiseWidgetAttributes.ContentState {
         PuffwiseWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PuffwiseWidgetAttributes.preview) {
   PuffwiseWidgetLiveActivity()
} contentStates: {
    PuffwiseWidgetAttributes.ContentState.smiley
    PuffwiseWidgetAttributes.ContentState.starEyes
}
