import Common
import WatchConnectivity
import SwiftUI

struct FeedingView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isShowingActionSheet = false
    let feeding: Feeding

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
                    self.store.send(.feeding(.stop(type: type)))
                case .pause:
                    self.store.send(.feeding(.pause(type: type)))
                case .resume:
                    self.store.send(.feeding(.resume(type: type)))
                }
        },
            errorHandler: { error in
                // TODO: show communication error
                print("Error sending the message: \(error.localizedDescription)")
                assertionFailure()
        })
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(feeding.isPaused ? "PAUSED" : "\(timerString(from: feeding.duration()))")
                .font(.system(size: 32, weight: .semibold))
            HStack(alignment: .center) {
                Text("\(feeding.type.rawValue)")
                    .font(.caption)
                + Text(" (\(feeding.side.asText()))".lowercased())
                    .font(.footnote)
                    .foregroundColor(.gray)
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
    static var previews: some View {
        FeedingView(store: Store(initialValue: AppState(), reducer: appReducer),
                    feeding: Feeding(start: Date(), type: .nursing, side: .left))
    }
}
