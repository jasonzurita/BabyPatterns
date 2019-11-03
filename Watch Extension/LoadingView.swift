import SwiftUI

struct LoadingView: View {
    @State var isAnimating = false
    func start() {
        withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }

    var body: some View {
        GeometryReader { metrics in
            Circle()
                .trim(from: 0, to: self.isAnimating ? 0 : 1)
                .stroke(Color.blue, lineWidth: 5.0)
                .frame(width: metrics.size.width * 0.3,
                       height: metrics.size.width * 0.3)
                .rotationEffect(Angle(degrees: self.isAnimating ? 0 : 360))
        }
        .onAppear {
            self.start()
        }
    }
}

// swiftlint:disable type_name
struct LoadingView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        LoadingView()
    }
}
