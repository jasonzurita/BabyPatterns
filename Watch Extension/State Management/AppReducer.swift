import Swift

let appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(accountStatusReducer, value: \.sessionState, action: \.session),
    pullback(pulseReducer, value: \.timerPulseCount, action: \.pulse),
    pullback(savedFyiDialogReducer, value: \.showSavedFyiDialog, action: \.savedFyiDialog),
    pullback(feedingReducer, value: \.self, action: \.feeding)
)
