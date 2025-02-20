//
//  LotteryWidgetLiveActivity.swift
//  LotteryWidget
//
//  Created by evan on 2025/2/20.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LotteryWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LotteryWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LotteryWidgetAttributes.self) { context in
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

extension LotteryWidgetAttributes {
    fileprivate static var preview: LotteryWidgetAttributes {
        LotteryWidgetAttributes(name: "World")
    }
}

extension LotteryWidgetAttributes.ContentState {
    fileprivate static var smiley: LotteryWidgetAttributes.ContentState {
        LotteryWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LotteryWidgetAttributes.ContentState {
         LotteryWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LotteryWidgetAttributes.preview) {
   LotteryWidgetLiveActivity()
} contentStates: {
    LotteryWidgetAttributes.ContentState.smiley
    LotteryWidgetAttributes.ContentState.starEyes
}
