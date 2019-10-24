import SwiftUI

struct FyiDialog: View {
    // TODO: remove the requirement to have the full store
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isShowing = false
    let screenWidthPercent: CGFloat
    private let disappearDuration: TimeInterval = 0.45

    private func sideDimention(for metrics: GeometryProxy) -> CGFloat {
        isShowing ? metrics.size.width * screenWidthPercent : 10
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundColor(Color.gray)
                    .opacity(0.96)

                Text("Saved!")
                    .scaledFont(.notoSansBold, size: 16)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .opacity(self.isShowing ? 1.0 : 0.0)
                    .animation(.none)
            }
            .frame(width: self.sideDimention(for: metrics),
                   height: self.sideDimention(for: metrics))
        }
        .opacity(isShowing ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring()) {
                self.isShowing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeIn(duration: self.disappearDuration)) {
                    self.isShowing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.disappearDuration) {
                        self.store.send(.savedFyiDialog(.hideSavedFyiDialog))
                    }
                }
            }
        }
    }
}

// swiftlint:disable type_name
struct FyiDialog_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        FyiDialog(store: Store(initialValue: AppState(), reducer: appReducer),
                  screenWidthPercent: 0.5)
    }
}
