import SwiftUI

struct FeedingView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isShowingActionSheet = false
    let feeding: Feeding
    var body: some View {
        VStack(alignment: .center) {
            Text("00:00:00")
                .font(.title)
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
                            // TODO: make this real
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
