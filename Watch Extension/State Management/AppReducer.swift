import Swift

let appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(accountStatusReducer, value: \.sessionState, action: \.session),
    pullback(pulseReducer, value: \.timerPulseCount, action: \.pulse),
    pullback(savedFyiDialogReducer, value: \.showSavedFyiDialog, action: \.savedFyiDialog),
    pullback(newFeedingReducer, value: \.self, action: \.newFeeding),
    pullback(feedingReducer, value: \.activeFeedings, action: \.feeding),
    pullback(contextReducer, value: \.self, action: \.context)
)
