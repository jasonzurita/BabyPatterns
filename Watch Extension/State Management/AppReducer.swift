import Swift

let appReducer: Reducer<AppState, AppAction> = combine(
    pullback(accountStatusReducer, value: \.sessionState, action: \.session),
    pullback(pulseReducer, value: \.timerPulseCount, action: \.pulse),
    pullback(savedFyiDialogReducer, value: \.showSavedFyiDialog, action: \.savedFyiDialog),
    pullback(communicationErrorFyiDialogReducer,
             value: \.showCommunicationErrorFyiDialog,
             action: \.communicationErrorFyiDialog),
    pullback(feedingReducer, value: \.feedingState, action: \.feeding),
    pullback(contextReducer, value: \.showCommunicationErrorFyiDialog, action: \.context)
)
