//
//  main.swift
//  CVGenerator
//
//  Created by bsbl on 07.02.20.
//

import Foundation

// start execution now
log("CVGenerator: Start")
try? CVCli(args: CommandLine.arguments).run()
log("CVGenerator: End")
