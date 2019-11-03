import SwiftUI

struct LoggedInHomeView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isShowingSheet = false

    private func alertDimension(for metrics: GeometryProxy) -> CGFloat {
        metrics.size.width * 0.9
    }

    var body: some View {
        ZStack {
            // TODO: think more about the layout of these two
            VStack {
                if store.value.activeFeedings.isEmpty {
                    Spacer()
                    // TODO: maybe add an image behind the text?
                    Text("No active feedings")
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .scaledFont(.notoSansSemiBold, size: 22)
                        .foregroundColor(Color.gray)
                        .layoutPriority(1)
                    Spacer()
                    Spacer()
                } else {
                    List(store.value.activeFeedings.reversed()) { feeding in
                        HStack {
                            Spacer()
                            FeedingView(store: self.store, feeding: feeding)
                                .layoutPriority(1.0)
                            Spacer()
                        }
                    }
                }

                // TODO: better style this
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .rotationEffect(.init(degrees: 45))
                    .offset(y: -10)
                    .sheet(isPresented: $isShowingSheet) {
                        AddFeedingView(store: self.store, isShowingSheet: self.$isShowingSheet)
                    }
                    .gesture(TapGesture().onEnded {
                        self.isShowingSheet.toggle()
                    })
            }
            .edgesIgnoringSafeArea(.bottom)

            if store.value.showCommunicationErrorFyiDialog {
                FyiDialog(text: Text("Oh no!\nPlease try again."),
                           screenWidthPercent: 0.75,
                           backgroundColor: Color.red,
                           displayDuration: 1.5,
                           endAction: { self.store.send(.communicationErrorFyiDialog(.hide)) })
            } else if store.value.showSavedFyiDialog {
                FyiDialog(text: Text("Saved!"),
                           screenWidthPercent: 0.5,
                           backgroundColor: Color.gray,
                           displayDuration: 1,
                           endAction: { self.store.send(.fyiDialog(.hide)) })
            } else if store.value.isLoading {
                LoadingView()
            }
        }
    }
}

// swiftlint:disable type_name
struct LoggedInHomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        LoggedInHomeView(store: Store(initialValue: AppState(), reducer: appReducer))
    }
}
