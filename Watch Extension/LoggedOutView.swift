import SwiftUI

struct LoggedOutHomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome!")
                .scaledFont(.notoSansBold, size: 30)
            Spacer()
            Text("Create an account using the main app to get started!")
                .scaledFont(.notoSansRegular, size: 18)
                .foregroundColor(.gray)
                .layoutPriority(1.0)
            Spacer()
        }
        .multilineTextAlignment(.center)
    }
}

// swiftlint:disable type_name
struct LoggedOutHomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        LoggedOutHomeView()
    }
}
