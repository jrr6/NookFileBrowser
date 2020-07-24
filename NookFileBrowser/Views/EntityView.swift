//
//  EntityView.swift
//  NookFileBrowser
//
//  Created by aaplmath on 3/19/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import SwiftUI

struct EntityView : View {
    var entity: DiskManager.Entity
    @Binding var pwd: String
    var downloadAction: (String) -> Void
    var deleteAction: (String) -> Void
    
    private var fullPath: String
    @State var alertShown = false
    
    init(entity: DiskManager.Entity, pwd: Binding<String>, downloadAction: @escaping (String) -> Void, deleteAction: @escaping (String) -> Void) {
        self.entity = entity
        self._pwd = pwd
        self.downloadAction = downloadAction
        self.deleteAction = deleteAction
        self.fullPath = pwd.wrappedValue + "/" + entity.name
    }
    
    var body: some View {
        Group {
            if entity.type == .directory {
                FolderView(entity.name, hidden: entity.hidden)
                    .onTapGesture {
                        self.pwd += "/" + self.entity.name
                    }
            } else {
                FileView(entity.name, hidden: entity.hidden)
                    .onTapGesture(count: 2) {
                        self.downloadAction(self.fullPath)
                    }
            }
        }
        .alert(isPresented: $alertShown) {
            Alert(title: Text("CAUTION: Confirm Deletion"),
                  message: Text("The following path will be permanently, irretrievably deleted:\n\n\(self.fullPath)"),
                  primaryButton: Alert.Button.destructive(Text("Delete")) {
                        self.deleteAction(self.fullPath)
                  },
                  secondaryButton: Alert.Button.cancel()
            )
        }
        .contextMenu {
            Button(action: {
                self.downloadAction(self.fullPath)
            }) {
                Text("Download")
            }
            
            Button(action: {
                self.alertShown = true
            }) {
                Text("Delete")
            }
        }
    }
}

struct FolderView : View {
    var name: String
    var hidden: Bool
    
    var body: some View {
        HStack {
            Image(nsImage: NSImage(named: NSImage.folderName)!)
            Text(name)
        }.opacity(hidden ? 0.75 : 1)
    }
    
    init(_ name: String, hidden: Bool = false) {
        self.name = name
        self.hidden = hidden
    }
}

struct FileView : View {
    var name: String
    var hidden: Bool
    private var fileType: String?
    
    var body: some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFileType: fileType ?? ""))
            Text(name)
        }.opacity(hidden ? 0.75 : 1)
    }
    
    init(_ name: String, hidden: Bool) {
        self.name = name
        self.hidden = hidden
        
        if let idx = name.lastIndex(of: "."), idx < name.endIndex {
            self.fileType = String(name[name.index(after: idx)...])
        }
    }
}

struct EntityView_Previews: PreviewProvider {
    static var previews: some View {
        EntityView(entity: DiskManager.Entity(name: "My file with a horrendously long name that will probably spill over.epub", type: .file, hidden: false), pwd: .constant("/sdcard/NOOK/My Files"), downloadAction: { _ in }, deleteAction: { _ in })
    }
}
