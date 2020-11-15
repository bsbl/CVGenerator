//
//  CVLatexPdf.swift
//  CVGenerator
//
//  Created by bsbl on 15.03.20.
//

import Foundation

class CVLatexPdf {
    
    func buildPdf(texFile: URL, outputPdfDir: String) -> (exit: Int, output: String) {
        //pdflatex /path/to/myfile.tex --output-directory=../otherdir
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = [
            "-c",
            "cd \(outputPdfDir) && /Library/TeX/texbin/lualatex \(texFile.path) --interaction batchmode"
        ]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return (exit: Int(process.terminationStatus), output: output)
    }
    
}
