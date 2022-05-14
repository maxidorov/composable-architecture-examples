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

enum TodoAction {
  case checkboxTapped
  case textFieldchanged(String)
}

struct TodoEnvironment {

}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
  case .checkboxTapped:
    state.isComplete.toggle()
    return .none
  case let .textFieldchanged(text):
    state.description = text
    return .none
  }
}

struct AppState: Equatable {
  var todos: [Todo]
}

enum AppAction {
  case addButtonTapped
  case todo(index: Int, action: TodoAction)
}

struct AppEnvironment {

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
    case .addButtonTapped:
      state.todos.insert(Todo(id: UUID()), at: 0)
      return .none
    case .todo:
      return .none
    }
  }
)

struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        List {
          ForEachStore(
            store.scope(state: \.todos, action: AppAction.todo(index:action:)),
            content: TodoView.init(store:)
          )
        }
        .navigationTitle("Todos")
        .navigationBarItems(trailing: Button("Add") {
          viewStore.send(.addButtonTapped, animation: .default)
        })
      }
    }
  }
}

struct TodoView: View {
  let store: Store<Todo, TodoAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button(action: {
          viewStore.send(.checkboxTapped)
        }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())

        TextField(
          "Unititled todo",
          text: viewStore.binding(
            get: \.description,
            send: TodoAction.textFieldchanged
          )
        )
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
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
