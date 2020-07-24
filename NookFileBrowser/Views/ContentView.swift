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
    
    // TODO: Figure out why rows switch to center alignment when text becomes multiline
    
    var body: some View {
        VStack(alignment: .leading) {
            TopBar(pwd: $manager.pwd, showHidden: $showHidden)
            
            if manager.loadFailure {
                VStack {
                    Text("Unable to load files. Is the device connected and adb installed?")
                        .padding()
                    
                    Button(action: {
                        self.manager.forceRefreshFilesList()
                    }) {
                        Text("Retry")
                    }.padding()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // Iterate with an inner ForEach because having empty List items (i.e., what we'd get iterating with a List when showHidden == false) creates ugly gaps
                    ForEach(manager.contents) { entity in
                        if !entity.hidden || self.showHidden {
                            EntityView(entity: entity, pwd: self.$manager.pwd, downloadAction: self.manager.downloadFile, deleteAction: self.manager.deleteFile)
                                // Ensures views remain leading edge-aligned, even when text becomes multiline due to width constraints
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                    }
                }
                .onDrop(of: [kUTTypeFileURL as String], isTargeted: $targeted) { providers in
                    self.manager.uploadFiles(providers)
                    return true
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
        }.alert(isPresented: $manager.isPendingError) {
            Alert(title: Text("Error"),
                  message: Text(manager.pendingErrorMessage ?? "Error message not found."),
                  dismissButton: Alert.Button.default(Text("OK")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
