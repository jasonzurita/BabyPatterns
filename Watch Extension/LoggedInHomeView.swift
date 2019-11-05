import SwiftUI

struct LoggedInHomeView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isShowingSheet = false

    private func alertDimension(for metrics: GeometryProxy) -> CGFloat {
        metrics.size.width * 0.9
    }

    var body: some View {
        ZStack {
            VStack {
                if store.value.activeFeedings.isEmpty {
                    Spacer()
                    ZStack {
                        Image("feet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(1.2)
                            .opacity(0.4)
                        Text("Start")
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .scaledFont(.notoSansSemiBold, size: 26)
                            .foregroundColor(.bpLightestGray)
                    }
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

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .rotationEffect(.init(degrees: 45))
                    .offset(y: -10)
                    .sheet(isPresented: $isShowingSheet) {
                        AddFeedingView(store: self.store, isShowingSheet: self.$isShowingSheet)
                    }
                    .foregroundColor(.bpLightestGray)
                    .gesture(TapGesture().onEnded {
                        self.isShowingSheet.toggle()
                    })
            }
            .edgesIgnoringSafeArea(.bottom)

            if store.value.showCommunicationErrorFyiDialog {
                FyiDialog(text: Text("Oh no!\nPlease try again."),
                           screenWidthPercent: 0.75,
                           // TODO: need a red color
                           backgroundColor: Color.red,
                           displayDuration: 1.6,
                           endAction: { self.store.send(.communicationErrorFyiDialog(.hide)) })
            } else if store.value.showSavedFyiDialog {
                FyiDialog(text: Text("Saved!"),
                           screenWidthPercent: 0.5,
                           backgroundColor: .bpMediumGray,
                           displayDuration: 1.25,
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
