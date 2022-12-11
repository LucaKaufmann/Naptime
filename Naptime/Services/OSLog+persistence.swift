//
//  OSLog+persistence.swift
//  Naptime
//
//  Created by Luca Kaufmann on 5.12.2022.
//

import os.log

extension OSLog {
    static let persistence = OSLog(subsystem: "Persistence", category: "coreData")
}
