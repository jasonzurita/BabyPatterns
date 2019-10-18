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
                self.store.send(.resume(fip))
            }
        } else {
            return .default(Text("Pause")) {
                self.store.send(.pause(fip))
            }
        }
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
                                self.store.send(.stop(self.feeding))
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
