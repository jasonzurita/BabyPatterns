import SwiftUI

struct LoggedInHomeView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isShowingSheet = false
    var body: some View {
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
                .font(.system(size: 55))
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
    }
}

// swiftlint:disable type_name
struct LoggedInHomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        HomeView(store: Store(initialValue: AppState(), reducer: appReducer))
    }
}
