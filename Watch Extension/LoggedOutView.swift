import SwiftUI

struct LoggedOutHomeView: View {
    @ObservedObject var store: Store<Void, ContextAction>

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome!")
                .scaledFont(.notoSansBold, size: 30)
            Text("No account found.\nRetry?")
                .scaledFont(.notoSansRegular, size: 16)
                .foregroundColor(.bpMediumGray)
                .layoutPriority(1.0)
            Button(action: {
                self.store.send(.requestFullContext)
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 36))
                    .foregroundColor(.bpMediumBlue)
            })
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .multilineTextAlignment(.center)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// swiftlint:disable type_name
struct LoggedOutHomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static let store = Store(initialValue: AppState(), reducer: appReducer)
    static var previews: some View {
        LoggedOutHomeView(store:
            store.view(
                value: { _ in },
                action: { .context($0) }
            )
        )
    }
}
