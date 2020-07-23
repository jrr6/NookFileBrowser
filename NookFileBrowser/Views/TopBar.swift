//
//  TopBar.swift
//  NookFileBrowser
//
//  Created by aaplmath on 3/19/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import SwiftUI

struct TopBar : View {
    @Binding var pwd: String
    @Binding var showHidden: Bool

    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                self.pwd = Constants.homePath
            }) {
                Image(nsImage: NSImage(named: NSImage.homeTemplateName)!)
            }
            Button(action: {
                self.pwd = String(self.pwd[..<(self.pwd.lastIndex(of: "/") ?? self.pwd.startIndex)])
            }) {
                Text("⤴")
            }
            Text(pwd.isEmpty ? "/" : pwd)
            Spacer()
            Toggle(isOn: $showHidden) {
                Text("Show All")
            }
        }.padding([.top, .leading, .trailing])
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar(pwd: .constant("/"), showHidden: .constant(false))
    }
}
