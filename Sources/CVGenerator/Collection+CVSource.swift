//
//  Collection+CVSource.swift
//  CVGenerator
//
//  Created by bsbl on 15.02.20.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
