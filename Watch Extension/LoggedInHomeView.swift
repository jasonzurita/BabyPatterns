import SwiftUI
import Cycle
import Common

struct LoggedInHomeView: View {
    @ObservedObject var store: Store<[Feeding], FeedingAction>
    @State private var isShowingSheet = false

    private func alertDimension(for metrics: GeometryProxy) -> CGFloat {
        metrics.size.width * 0.9
    }

    var body: some View {
        ZStack {
            VStack {
                if store.value.isEmpty {
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
                    List(store.value.reversed()) { feeding in
                        HStack(spacing: -10) {
                            Spacer()
                            FeedingView(store:
                                self.store.view(
                                    value: { $0 },
                                    action: { $0 }
                                ), feeding: feeding)
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
                        AddFeedingView(store:
                            self.store.view(
                                value: { $0 },
                                action: { $0 }
                        ), isShowingSheet: self.$isShowingSheet)
                    }
                    .foregroundColor(.bpLightestGray)
                    .gesture(TapGesture().onEnded {
                        self.isShowingSheet.toggle()
                    })
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// swiftlint:disable type_name
struct LoggedInHomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static let store = Store(initialValue: AppState(), reducer: appReducer)
    static let singleFeedingStore = Store(initialValue: AppState.singleFeedingMock, reducer: appReducer)

    static var previews: some View {
        Group {
            LoggedInHomeView(store:
                singleFeedingStore.view(
                    value: { $0.activeFeedings },
                    action: { .feeding($0) }
                )
            )
            LoggedInHomeView(store:
                store.view(
                    value: { $0.activeFeedings },
                    action: { .feeding($0) }
                )
            )
        }
    }
}
