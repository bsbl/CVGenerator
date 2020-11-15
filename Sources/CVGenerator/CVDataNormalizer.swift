//
//  CVDataNormalizer.swift
//  CVGenerator
//
//  Created by bsbl on 20.04.20.
//

import Foundation

class CVDataNormalizer {
    
    static var escapedCharacters: Set<Character> = Set(arrayLiteral: "#","&","%")
    
    static func normalizeData(_ line: String) -> String {
        return line.map {
            escapedCharacters.contains($0) ?
                "\\\($0)" : "\($0)"
            }.joined()
    }
    
    static func addBullets(_ line: String) -> String {
        return "\\begin{itemize}\\item " + line.split(separator: "\n").joined(separator: "\\item ") + "\\end{itemize}"
    }
}
