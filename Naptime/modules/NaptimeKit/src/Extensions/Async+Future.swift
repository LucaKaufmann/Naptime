//
//  Async+Future.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.12.2022.
//

import Foundation
import Combine

extension Future where Failure == Error {
    convenience init(asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
