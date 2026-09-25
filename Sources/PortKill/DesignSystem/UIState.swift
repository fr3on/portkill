import SwiftUI

@propertyWrapper
struct UIState<Value>: DynamicProperty {
    private var state: SwiftUI.State<Value>

    init(wrappedValue: Value) {
        self.state = SwiftUI.State(initialValue: wrappedValue)
    }

    var wrappedValue: Value {
        get { state.wrappedValue }
        nonmutating set { state.wrappedValue = newValue }
    }

    var projectedValue: Binding<Value> {
        state.projectedValue
    }
}
