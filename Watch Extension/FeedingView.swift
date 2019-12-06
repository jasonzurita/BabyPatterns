import Common
import SwiftUI
import WatchConnectivity

struct FeedingView: View {
    @ObservedObject var store: Store<[Feeding], FeedingAction>
    let feeding: Feeding
    @State private var isShowingActionSheet = false

    private func timerString(from seconds: TimeInterval) -> String {
        let hours = seconds.stringFromSecondsToHours(zeroPadding: true)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
        let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

        return hours.string + ":" + minutes.string + ":" + seconds.string
    }

    private func actionSheetButton(_ fip: Feeding) -> Alert.Button {
        if fip.isPaused {
            return .default(Text("Resume")) {
                self.store.send(.communicate(type: fip.type, side: fip.side, action: .resume))
            }
        } else {
            return .default(Text("Pause")) {
                self.store.send(.communicate(type: fip.type, side: fip.side, action: .pause))
            }
        }
    }

    private func color(for type: FeedingType) -> Color {
        switch type {
        case .nursing: return .bpPink
        case .pumping: return .bpGreen
        case .bottle: return .bpMediumBlue
        case .none: fatalError()
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(feeding.isPaused ? "PAUSED" : "\(timerString(from: feeding.duration()))")
                .scaledFont(.notoSansRegular, size: 30)
                .layoutPriority(1)
            // TODO: get these to align better with the timer label
            VStack(alignment: .center, spacing: -7) {
                Text("\(String(feeding.type.rawValue.prefix(1)))".uppercased())
                    .scaledFont(.notoSansBold, size: 16)
                    .foregroundColor(color(for: feeding.type))
                Text("\(feeding.side.asText().prefix(1))".uppercased())
                    .scaledFont(.notoSansSemiBold, size: 14)
                    .foregroundColor(.bpLightGray)
            }
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("What do you want to do?"),
                        buttons: [
                            .default(Text("Stop")) {
                                self.store.send(.communicate(type: self.feeding.type,
                                                             side: self.feeding.side,
                                                             action: .stop))
                            },
                            actionSheetButton(self.feeding),
                        ])
        }
        .gesture(TapGesture().onEnded {
            self.isShowingActionSheet.toggle()
        })
    }
}

// swiftlint:disable type_name
struct FeedingView_Previews: PreviewProvider {
// swiftlint:enable type_name

    static let store = Store(initialValue: AppState(), reducer: appReducer)

    static let feeding = Feeding(type: .nursing,
                                 side: .left,
                                 startDate: Date() - 3355,
                                 supplyAmount: .zero,
                                 pausedTime: 0)

    static let feedingPaused = Feeding(type: .nursing,
                                       side: .left,
                                       startDate: Date() - 3355,
                                       lastPausedDate: Date() + 5,
                                       supplyAmount: .zero,
                                       pausedTime: 0)

    static var previews: some View {
        Group {
            FeedingView(store:
                store.view(
                    value: { $0.activeFeedings },
                    action: { .feeding($0) }
                ), feeding: feeding
            )
            FeedingView(store:
                store.view(
                    value: { $0.activeFeedings },
                    action: { .feeding($0) }
                ), feeding: feedingPaused
            )
        }
    }
}
