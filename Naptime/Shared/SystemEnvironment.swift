//
//  SystemEnvironment.swift
//  Naptime
//
//  Created by Luca Kaufmann on 1.12.2022.
//


import ComposableArchitecture
import Foundation

@dynamicMemberLookup
struct SystemEnvironment<Environment> {
  var environment: Environment

  subscript<Dependency>(
    dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
  ) -> Dependency {
    get { self.environment[keyPath: keyPath] }
    set { self.environment[keyPath: keyPath] = newValue }
  }

  var mainQueue: () -> AnySchedulerOf<DispatchQueue>

  static func live(environment: Environment) -> Self {
    Self(environment: environment, mainQueue: { .main })
  }

  static func dev(environment: Environment) -> Self {
    Self(environment: environment, mainQueue: { .main })
  }
}

