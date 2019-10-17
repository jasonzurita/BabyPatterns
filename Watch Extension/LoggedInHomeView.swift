import SwiftUI

struct LoggedInHomeView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isShowingSheet = false

    private func alertDimension(for metrics: GeometryProxy) -> CGFloat {
        store.value.didCommunicationFail ? metrics.size.width * 0.9 : 10
    }

    var body: some View {
        ZStack {
            // TODO: think more about the layout of these two
            VStack {
                List(store.value.activeFeedings.reversed()) { feeding in
                    HStack {
                        Spacer()
                        FeedingView(store: self.store, feeding: feeding)
                            .layoutPriority(1.0)
                        Spacer()
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

            GeometryReader { metrics in
                ZStack {
                    Rectangle()
                        .cornerRadius(12)
                        .foregroundColor(Color.blue)
                        .opacity(0.96)

                    VStack {
                        Text("Connection Issue")
                            .bold()
                        Text("\nTry again or open main app.")
                            .layoutPriority(1.0)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .animation(.none)
                }
                .frame(width: self.alertDimension(for: metrics), height: self.alertDimension(for: metrics))
            }
            .opacity(self.store.value.didCommunicationFail ? 1.0 : 0.0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7))
            .gesture(TapGesture().onEnded {
                self.store.send(.clearFailedCommunication)
            })

            if store.value.showSavedFyiDialog {
                FyiDialog(store: store, screenWidthPercent: 0.5)
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
