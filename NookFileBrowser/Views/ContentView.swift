//
//  ContentView.swift
//  NookFileBrowser
//
//  Created by aaplmath on 3/16/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var manager = DiskManager()
    @State private var showHidden = false
    @State private var targeted = false
    
    // TODO: Add ability to push files (remember to trigger a sync after doing so!)
    // TODO: Figure out why rows switch to center alignment when text become multiline
    // TODO: Add Combine stuff to DiskManager
    
    var body: some View {
        VStack(alignment: .leading) {
            TopBar(pwd: $manager.pwd, showHidden: $showHidden)
            
            List {
                // Iterate with an inner ForEach because having empty List items (i.e., what we'd get iterating with a List when showHidden == false) creates ugly gaps
                ForEach(manager.contents) { entity in
                    if !entity.hidden || self.showHidden {
                        EntityView(entity: entity, pwd: self.$manager.pwd, downloadAction: self.manager.downloadFile)
                    }
                }
            }
            .onDrop(of: ["public.item"], isTargeted: $targeted) { provider in
                return false
            }
            .overlay(
                Rectangle().strokeBorder(
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [15]
                    )
                ).overlay(Rectangle().fill(Color.gray)).opacity(targeted ? 0.25 : 0)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}