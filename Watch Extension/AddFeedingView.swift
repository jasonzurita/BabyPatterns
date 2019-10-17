import Common
import SwiftUI

private func isAdding(feeding type: FeedingType) -> Bool {
    switch type {
    case .nursing, .pumping, .bottle: return true
    case .none: return false
    }
}

// TODO: should we show all the start feeding options if there is already an
// active feeding going for that type?
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
                    .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
                    .opacity(isAdding(feeding: feedingIntent) ? 0.5 : 1.0)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { self.feedingIntent = .nursing }
                    })
                Spacer()
                Spacer()
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 55))
                    .scaleEffect(isAdding(feeding: feedingIntent) ? 0.5 : 1)
                    .opacity(isAdding(feeding: feedingIntent) ? 0.5 : 1.0)
                    .blur(radius: isAdding(feeding: feedingIntent) ? 1.0 : 0)
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
                            self.store.send(.start(type: self.feedingIntent, side: .left))
                            self.isShowingSheet = false
                        })

                    Image(systemName: "r.circle")
                        .font(.system(size: 55))
                        .offset(x: isAdding(feeding: self.feedingIntent) ? 45 : metrics.size.width * 0.5 + 50)
                        .gesture(TapGesture().onEnded {
                            self.store.send(.start(type: self.feedingIntent, side: .right))
                            self.isShowingSheet = false
                        })
                }
            }
        }
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
