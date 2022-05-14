//
//  ContentView.swift
//  Todos
//
//  Created by MSP on 14.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Identifiable, Equatable {
  var description = ""
  var id: UUID
  var isComplete = false
}

struct AppState: Equatable {
  var todos: [Todo]
}

enum AppAction {
  case todoCheckboxTapped(index: Int)
  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case let .todoCheckboxTapped(index):
    state.todos[index].isComplete.toggle()
    return .none
  case let .todoTextFieldChanged(index, text):
    state.todos[index].description = text
    return .none
  }
}.debug()

struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        List {
          ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
            HStack {
              Button(action: {
                viewStore.send(.todoCheckboxTapped(index: index))
              }) {
                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
              }
              .buttonStyle(PlainButtonStyle())

              TextField(
                "Unititled todo",
                text: viewStore.binding(
                  get: { $0.todos[index].description },
                  send: { .todoTextFieldChanged(index: index, text: $0) }
                )
              )
            }
            .foregroundColor(todo.isComplete ? .gray : nil)
          }
        }
      }
      .navigationTitle("Todos")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(todos: todos),
        reducer: appReducer,
        environment: AppEnvironment()
      )
    )
  }
}

let todos: [Todo] = [
  .init(description: "Milk", id: UUID(), isComplete: false),
  .init(description: "Eggs", id: UUID(), isComplete: true),
  .init(description: "Bananas", id: UUID(), isComplete: false),
]
