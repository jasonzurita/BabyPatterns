import Common
import Cycle
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
    let activeFeedingTypes: [FeedingType]

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .nursing }
                }, label: {
                    Image(systemName: "n.circle.fill")
                        .font(.system(size: 55))
                        .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                        .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
                })
                .buttonStyle(PlainButtonStyle())
                .disabled(activeFeedingTypes.contains(.nursing))

                Spacer()
                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .pumping }
                }, label: {
                    Image(systemName: "p.circle.fill")
                        .font(.system(size: 55))
                        .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                        .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
                })
                .buttonStyle(PlainButtonStyle())
                .disabled(activeFeedingTypes.contains(.pumping))
                Spacer()
            }
            Spacer()
        }
    }
}

struct AddFeedingView: View {
    @ObservedObject var store: Store<[Feeding], FeedingAction>
    @Binding var isShowingSheet: Bool
    @State private var feedingIntent: FeedingType = .none

    var body: some View {
        ZStack {
            // Keep an eye on the below `activeFeedingTypes`. I am not sure if changes to the
            // store will reflect in the below view since we are just passing an array in and
            // not some kind of binding
            FeedingOptionsView(feedingIntent: $feedingIntent,
                               activeFeedingTypes: store.value.map { $0.type })
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
                        .foregroundColor(.bpLightestGray)
                        // TODO: These numbers are not exact, figure this out better
                        .offset(x: isAdding(feeding: self.feedingIntent) ? -45 : -metrics.size.width * 0.5 - 50)
                        .gesture(TapGesture().onEnded {
                            self.store.send(.communicate(type: self.feedingIntent, side: .left, action: .start))
                            self.isShowingSheet = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })

                    Image(systemName: "r.circle")
                        .font(.system(size: 55))
                        .foregroundColor(.bpLightestGray)
                        .offset(x: isAdding(feeding: self.feedingIntent) ? 45 : metrics.size.width * 0.5 + 50)
                        .gesture(TapGesture().onEnded {
                            self.store.send(.communicate(type: self.feedingIntent, side: .right, action: .start))
                            self.isShowingSheet = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .none }
                        })
                }
            }
        }
    }
}

// swiftlint:disable type_name
struct AddFeedingView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static let store = Store(initialValue: AppState(), reducer: appReducer)
    static var previews: some View {
        AddFeedingView(store:
            store.view(
                value: { $0.activeFeedings },
                action: { .feeding($0) }
            ), isShowingSheet: .constant(true)
        )
    }
}
