import SwiftUI

/*
 TODO: - V1 Watch
 - Polish UI
 - Make running feedings a live list
 - Make sure a backgrounded/terminated main app
   behaves well from a UI standpoint when using the watch
 - App icon
 - Think about subscriptions or IAP for this
 - Better formalize communication instead of basing it off
   of yucky strings
 - Add unidirectional flow architecture for better state management
 - Allow stopping current feeding
 - Allow pausing current feeding
 */

struct HomeView: View {
    @State private var isShowingSheet = false
    var body: some View {
        // TODO: think more about the layout of these two
        VStack {
            // TODO: fill this in with active feedings
            List(1 ... 10, id: \.self) { _ in
                Text("00:00:00")
            }
            // TODO: better style this
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 55))
                .rotationEffect(.init(degrees: 45))
                .offset(y: -10)
                .sheet(isPresented: $isShowingSheet) {
                    AddFeedingView(isShowingSheet: self.$isShowingSheet)
                }
                .gesture(TapGesture().onEnded {
                    self.isShowingSheet.toggle()
                })
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// swiftlint:disable type_name
struct HomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        HomeView()
    }
}
