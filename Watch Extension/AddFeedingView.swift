import Common
import WatchConnectivity
import SwiftUI

private func isAdding(feeding type: FeedingType) -> Bool {
    switch type {
    case .nursing, .pumping, .bottle: return true
    case .none: return false
    }
}

struct FeedingOptionsView: View {
    @Binding var feedingIntent: FeedingType
    let activeFeedingTypes: [FeedingType]

    private func opacity(for type: FeedingType) -> Double {
        isAdding(feeding: feedingIntent) || activeFeedingTypes.contains(type)
            ? 0.5 : 1.0
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "n.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
                    .opacity(opacity(for: .nursing))
                    .disabled(activeFeedingTypes.contains(.nursing))
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .nursing }
                    })
                Spacer()
                Spacer()
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .opacity(opacity(for: .pumping))
                    .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
                    .disabled(activeFeedingTypes.contains(.pumping))
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .pumping }
                    })
                Spacer()
            }
            Spacer()
        }
    }
}

struct AddFeedingView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @Binding var isShowingSheet: Bool
    @State private var feedingIntent: FeedingType = .none

    var body: some View {
        ZStack {
            // Keep an eye on the below `activeFeedingTypes`. I am not sure if changes to the
            // store will reflect in the below view since we are just passing an array in and
            // not some kind of binding
            FeedingOptionsView(feedingIntent: $feedingIntent,
                               activeFeedingTypes: store.value.activeFeedings.map { $0.type })
            GeometryReader { metrics in
                ZStack {
                    Rectangle()
                        .opacity(isAdding(feeding: self.feedingIntent) ? 0.5 : 0)
                        .foregroundColor(Color.black)
                        .gesture(TapGesture().onEnded {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })

                    Image(systemName: "l.circle")
                        .font(.system(size: 55))
                        // TODO: These numbers are not exact, figure this out better
                        .offset(x: isAdding(feeding: self.feedingIntent) ? -45 : -metrics.size.width * 0.5 - 50)
                        .gesture(TapGesture().onEnded {
                            self.communicateFeedingStart(type: self.feedingIntent, side: .left)
                            // TODO: show spinner here
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })

                    Image(systemName: "r.circle")
                        .font(.system(size: 55))
                        .offset(x: isAdding(feeding: self.feedingIntent) ? 45 : metrics.size.width * 0.5 + 50)
                        .gesture(TapGesture().onEnded {
                            self.communicateFeedingStart(type: self.feedingIntent, side: .right)
                            // TODO: show spinner here
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })
                }
            }
        }
    }

    // TODO: consider making this a global function or in the session coordinator or ?
    // This is the first time of copy and paste
    func communicateFeedingStart(type: FeedingType, side: FeedingSide) {
        let info = WatchCommunication(type: type, side: side, action: .start)

        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            // TODO: show communication error
            return
        }

        WCSession.default.sendMessageData(
            d,
            replyHandler: { _ in
                self.store.send(.newFeeding(.start(type: type, side: side)))
                self.isShowingSheet = false
        },
            errorHandler: { error in
                // TODO: show communication error
                print("Error sending the message: \(error.localizedDescription)")
                assertionFailure()
        })
    }
}

// swiftlint:disable type_name
struct AddFeedingView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        AddFeedingView(store: Store(initialValue: AppState(), reducer: appReducer),
                       isShowingSheet: .constant(true))
    }
}
