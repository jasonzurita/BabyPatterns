import SwiftUI

struct LoggedOutHomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome!")
                .font(.title)
            Spacer()
            Text("Create an account using the main app to get started!")
                .font(.callout)
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
