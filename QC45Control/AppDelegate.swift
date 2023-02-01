//
//  AppDelegate.swift
//  QC45Control
//
//  Created by Niklas Arnitz on 01.02.23.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarItem: NSStatusItem!
    private var bluetooth: BluetoothHelper!
    
    private let header = NSMenuItem(title: "QC35 Control", action: nil, keyEquivalent: "")
    private let quietMode = NSMenuItem(title: "Quiet Mode", action: #selector(didTapQuietMode), keyEquivalent: "")
    private let awareMode = NSMenuItem(title: "Aware Mode", action: #selector(didTapAwareMode), keyEquivalent: "")
    private let quit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    private var isInQuietMode = false {
        didSet {
            if(isInQuietMode) {
                quietMode.title = "✅ Quiet Mode"
                awareMode.title = "Aware Mode"
            } else {
                quietMode.title = "Quiet Mode"
                awareMode.title = "✅ AwareMode"
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup StatusBar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "headphones", accessibilityDescription: "1")
        }
        
        // Setup Bluetooth
        bluetooth = BluetoothHelper()
        bluetooth.discover()
        
        // Setup Menus
        setupMenus()
    }
    
    func setupMenus() {
        let menu = NSMenu()
        
        menu.addItem(header)
        menu.addItem(quietMode)
        menu.addItem(awareMode)
        menu.addItem(quit)
        
        statusBarItem.menu = menu
    }
    
    @objc func didTapQuietMode() {
        bluetooth.switchToQuietMode()
        isInQuietMode = true
    }
    
    @objc func didTapAwareMode() {
        bluetooth.switchToAwareMode()
        isInQuietMode = false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        bluetooth.close()
    }
}

