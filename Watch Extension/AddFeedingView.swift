import Common
import SwiftUI
import WatchConnectivity

private func isAdding(feeding type: FeedingType) -> Bool {
    switch type {
    case .nursing, .pumping, .bottle: return true
    case .none: return false
    }
}

struct FeedingOptionsView: View {
    @Binding var feedingIntent: FeedingType
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "n.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .nursing }
                    })
                Spacer()
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .pumping }
                    })
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "b.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .bottle }
                    })
                Spacer()
            }
            Spacer()
        }
    }
}

struct AddFeedingView: View {
    @Binding var isShowingSheet: Bool
    @State private var feedingIntent: FeedingType = .none

    var body: some View {
        ZStack {
            FeedingOptionsView(feedingIntent: $feedingIntent)
            GeometryReader { metrics in
                ZStack {
                    Rectangle()
                        .opacity(isAdding(feeding: self.feedingIntent) ? 0.5 : 0)
                        .foregroundColor(Color.black)
                        .gesture(TapGesture().onEnded {
                            // TODO: not a fan of duplicating this
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })

                    Image(systemName: "l.circle")
                        .font(.system(size: 55))
                        // TODO: These numbers are not exact, figure this out better
                        .offset(x: isAdding(feeding: self.feedingIntent) ? -45 : -metrics.size.width * 0.5 - 50)
                        .gesture(TapGesture().onEnded {
                            let info = WatchCommunication(type: self.feedingIntent,
                                                          side: .left,
                                                          action: .start)
                            let jsonEncoder = JSONEncoder()
                            guard let d = try? jsonEncoder.encode(info) else {
                                // TODO: what do we do here?
                                return
                            }
                            WCSession.default.sendMessageData(d, replyHandler: nil) { e in
                                print("Error sending the message: \(e.localizedDescription)")
                            }
                            self.isShowingSheet = false
                        })

                    Image(systemName: "r.circle")
                        .font(.system(size: 55))
                        .offset(x: isAdding(feeding: self.feedingIntent) ? 45 : metrics.size.width * 0.5 + 50)
                        .gesture(TapGesture().onEnded {
                            let info = WatchCommunication(type: self.feedingIntent,
                                                          side: .right,
                                                          action: .start)
                            let jsonEncoder = JSONEncoder()
                            guard let d = try? jsonEncoder.encode(info) else {
                                 // TODO: what do we do here?
                                 return
                             }
                            WCSession.default.sendMessageData(d, replyHandler: nil) { e in
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
