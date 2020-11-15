//
//  CVBasicLogger.swift
//  CVGenerator
//
//  Created by bsbl on 06.02.20.
//

import Foundation

enum LogLevel: String {
    case info = "INFO"
    case error = "ERROR"
    case warn = "WARN"
}

func log(_ msg: String, with logLevel: LogLevel = .info) {
    print("\(logLevel): \(msg)")
}
