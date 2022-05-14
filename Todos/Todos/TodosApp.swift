//
//  TodosApp.swift
//  Todos
//
//  Created by MSP on 14.05.2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodosApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(
          initialState: AppState(todos: todos),
          reducer: appReducer,
          environment: AppEnvironment()
        )
      )
    }
  }
}
