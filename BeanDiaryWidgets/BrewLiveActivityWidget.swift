import ActivityKit
import SwiftUI
import WidgetKit

struct BrewLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BrewActivityAttributes.self) { context in
            BrewLiveActivityLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.beanName)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text(context.state.stepLabel)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    BrewLiveActivityCountdownView(state: context.state)
                        .font(.title2.monospacedDigit())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        if let water = context.state.waterAmount {
                            Label("목표 \(water)g", systemImage: "drop.fill")
                                .font(.caption)
                        }
                        Text(context.state.instruction)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        ProgressView(value: context.state.overallProgress)
                            .tint(.orange)
                    }
                }
            } compactLeading: {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                BrewLiveActivityCountdownView(state: context.state)
                    .font(.caption.monospacedDigit())
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
        }
    }
}

private struct BrewLiveActivityLockScreenView: View {
    let context: ActivityViewContext<BrewActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.beanName)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    Text(context.state.stepLabel)
                        .font(.headline)
                        .lineLimit(1)
                }
                Spacer()
                BrewLiveActivityCountdownView(state: context.state)
                    .font(.title.monospacedDigit())
            }

            if let water = context.state.waterAmount {
                Label("목표 물량 \(water)g", systemImage: "drop.fill")
                    .font(.caption)
            }

            Text(context.state.instruction)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text("단계 \(context.state.currentStepIndex + 1)/\(context.attributes.totalSteps)")
                Spacer()
                Text("전체 \(BrewActivityFormatting.time(context.state.totalRemainingSec))")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            ProgressView(value: context.state.overallProgress)
                .tint(.orange)
        }
        .padding(.vertical, 4)
    }
}

private struct BrewLiveActivityCountdownView: View {
    let state: BrewActivityAttributes.ContentState

    var body: some View {
        if state.phase == .brewing, let end = state.stepEndDate {
            Text(timerInterval: Date.now...end, countsDown: true)
        } else if state.phase == .paused {
            Text(BrewActivityFormatting.time(state.stepRemainingSec))
                .foregroundStyle(.secondary)
        } else {
            Text(BrewActivityFormatting.time(state.stepRemainingSec))
        }
    }
}
