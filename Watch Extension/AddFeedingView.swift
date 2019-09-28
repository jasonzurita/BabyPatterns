import SwiftUI
import WatchConnectivity

struct FeedingOptionsView: View {
    @Binding var intent: AddingIntent
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "n.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(self.intent.isAdding ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.intent = .nursing }
                    })
                Spacer()
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(self.intent.isAdding ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.intent = .pumping }
                    })
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "b.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(self.intent.isAdding ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.intent = .bottle }
                    })
                Spacer()
            }
            Spacer()
        }
    }
}

// TODO: change this to be backed by an int
enum AddingIntent: String {
    // TODO: I may be able to use this enum from the main app
    case nursing, pumping, bottle, none

    var isAdding: Bool {
        switch self {
        case .nursing, .pumping, .bottle: return true
        case .none: return false
        }
    }
}

struct AddFeedingView: View {
    @Binding var isShowingSheet: Bool
    @State private var intent: AddingIntent = .none

    var body: some View {
        ZStack {
            FeedingOptionsView(intent: $intent)
            GeometryReader { metrics in
                ZStack {
                    Rectangle()
                        .opacity(self.intent.isAdding ? 0.5 : 0)
                        .foregroundColor(Color.black)
                        .gesture(TapGesture().onEnded {
                            // TODO: not a fan of duplicating this
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.intent = .none }
                        })

                    Image(systemName: "l.circle")
                        .font(.system(size: 55))
                        // TODO: These numbers are not exact, figure this out better
                        .offset(x: self.intent.isAdding ? -45 : -metrics.size.width * 0.5 - 50)
                        .gesture(TapGesture().onEnded {
                            WCSession.default.sendMessage(["feedingType": "\(self.intent.rawValue)", "side": "left"], replyHandler: { reply in
                                print(reply)
                            }) { e in
                                print("Error sending the message: \(e.localizedDescription)")
                            }
                            self.isShowingSheet = false
                        })

                    Image(systemName: "r.circle")
                        .font(.system(size: 55))
                        .offset(x: self.intent.isAdding ? 45 : metrics.size.width * 0.5 + 50)
                        .gesture(TapGesture().onEnded {
                            WCSession.default.sendMessage(["feedingType": "\(self.intent.rawValue)", "side": "right"], replyHandler: { reply in
                                print(reply)
                            }) { e in
                                print("Error sending the message: \(e.localizedDescription)")
                            }
                            self.isShowingSheet = false
                        })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddFeedingView(isShowingSheet: .constant(true))
    }
}
