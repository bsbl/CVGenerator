//
//  CVErrors.swift
//  CVGenerator
//
//  Created by bsbl on 08.02.20.
//

import Foundation

enum CVError: Error {
    case configError
    case fileNotFound(String)
    case noDataFound(String)
    case dataError(String)
}
