//
//  String+CVMain.swift
//  CVGenerator
//
//  Created by bsbl on 07.02.20.
//

import Foundation

extension String {
    init?(withSubstring: String.SubSequence?) {
        guard let substring = withSubstring else { return nil}
        self.init(substring)
    }
}
