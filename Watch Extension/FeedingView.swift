import SwiftUI

struct FeedingView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isShowingActionSheet = false
    let feeding: Feeding

    private func timerString(from date: Date) -> String {
        let timeInterval = abs(date.timeIntervalSinceNow)
        let hours = TimeInterval(timeInterval).stringFromSecondsToHours(zeroPadding: true)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
        let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

        return hours.string + ":" + minutes.string + ":" + seconds.string
    }

    var body: some View {
        VStack(alignment: .center) {
            if store.value.timerPulseCount >= 0 {
                Text("\(timerString(from: feeding.start))")
                    .font(.system(size: 32, weight: .semibold))
            }
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
                            // TODO: make this real, which can probably be accomplished
                            // by having a pullback on the store's state mutation
                            .default(Text("Pause/Resume")) {
                                self.store.send(.pause(self.feeding))
                            },
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
