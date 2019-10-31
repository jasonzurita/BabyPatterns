import SwiftUI

struct FyiDialog: View {
    let text: Text
    let screenWidthPercent: CGFloat
    let backgroundColor: Color
    let displayDuration: TimeInterval
    let endAction: () -> Void

    @State private var isShowing = false

    private func sideDimention(for metrics: GeometryProxy) -> CGFloat {
        isShowing ? metrics.size.width * screenWidthPercent : 10
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundColor(self.backgroundColor)
                    .opacity(0.98)

                self.text
                    .scaledFont(.notoSansSemiBold, size: 18)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + self.displayDuration) {
                withAnimation(.easeIn(duration: 0.45)) {
                    self.isShowing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.displayDuration) {
                        self.endAction()
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
        Group {
            FyiDialog(text: Text("Saved!"),
                      screenWidthPercent: 0.5,
                      backgroundColor: Color.gray,
                      displayDuration: 0.45,
                      endAction: {})
            FyiDialog(text: Text("Oh no!\nPlease try again."),
                      screenWidthPercent: 0.75,
                      backgroundColor: Color.red,
                      displayDuration: 0.7,
                      endAction: {})
            FyiDialog(text: Text("Hello World!"),
                      screenWidthPercent: 0.7,
                      backgroundColor: Color.blue,
                      displayDuration: 0.45,
                      endAction: {})
        }
    }
}
