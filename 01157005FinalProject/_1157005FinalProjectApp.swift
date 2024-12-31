//
//  _1157005FinalProjectApp.swift
//  01157005FinalProject
//
//  Created by user11 on 2024/11/27.
//

import SwiftUI

@main
struct _1157005FinalProjectApp: App {
    var body: some Scene {
        WindowGroup {
            //ReceiptCameraView()
           FortuneView()
        }
        .modelContainer(for: Fortune.self)
    }
}
