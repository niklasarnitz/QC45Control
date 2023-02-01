//
//  main.swift
//  QC45Control
//
//  Created by Niklas Arnitz on 01.02.23.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
