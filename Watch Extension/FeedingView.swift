import Common
import SwiftUI
import WatchConnectivity

struct FeedingView: View {
    @ObservedObject var store: Store<AppState, AppAction>
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
                self.communicate(type: fip.type, side: fip.side, action: .resume)
            }
        } else {
            return .default(Text("Pause")) {
                self.communicate(type: fip.type, side: fip.side, action: .pause)
            }
        }
    }

    // TODO: consider making this a global function or in the session coordinator or ?
    // This is the second time of copy and paste
    func communicate(type: FeedingType, side: FeedingSide, action: Common.FeedingAction) {
        let info = WatchCommunication(type: type, side: side, action: action)

        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            // TODO: show communication error
            return
        }

        WCSession.default.sendMessageData(
            d,
            replyHandler: { _ in
                switch action {
                case .start: break
                case .stop:
                    self.store.send(.newFeeding(.stop(type: type)))
                case .pause:
                    self.store.send(.newFeeding(.pause(type: type)))
                case .resume:
                    self.store.send(.newFeeding(.resume(type: type)))
                }
            },
            errorHandler: { error in
                // TODO: show communication error
                print("Error sending the message: \(error.localizedDescription)")
                assertionFailure()
            }
        )
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(feeding.isPaused ? "PAUSED" : "\(timerString(from: feeding.duration()))")
                .scaledFont(.notoSansBold, size: 32)
            // TODO: get these to align better with the timer label
            HStack(alignment: .center) {
                Spacer()
                Text("\(feeding.type.rawValue)")
                    .scaledFont(.notoSansRegular, size: 16)
                Spacer()
                Text("\(feeding.side.asText())".lowercased())
                    .scaledFont(.notoSansRegular, size: 16)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("What do you want to do?"),
                        buttons: [
                            .default(Text("Stop")) {
                                self.communicate(type: self.feeding.type, side: self.feeding.side, action: .stop)
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
            FeedingView(store: Store(initialValue: AppState(), reducer: appReducer),
                        feeding: FeedingView_Previews.feeding)
            FeedingView(store: Store(initialValue: AppState(), reducer: appReducer),
                        feeding: FeedingView_Previews.feedingPaused)
        }
    }
}
