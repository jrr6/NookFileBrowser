//
//  DiskManager.swift
//  NookFileBrowser
//
//  Created by aaplmath on 3/18/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import Foundation
import Combine

// Command to list files:
// for f in ""/{.,}*; do if [[ -e "$f" ]]; then if [[ -d "$f" ]]; then echo -n "d"; else echo -n "f"; fi; busybox basename "$f"; fi; done

class DiskManager : ObservableObject {
    struct Entity : Identifiable {
        enum ObjectType {
            case directory
            case file
        }
        
        var id: String {
            return String(type.hashValue) + name
        }
        
        var name: String
        var type: ObjectType
        var hidden: Bool
    }
    
    @Published var contents = [Entity]()
    
    private var cancellable: AnyCancellable!
    private var buffer: String = ""
    private var activeProc: Process! // only ever allow there to be one active process—having multiple concurrent fetches is wasteful and will lead to a race condition when writing to contents

    @Published var pwd: String = "" {
        willSet(pwd) {
            guard pwd != self.pwd else {
                // Avoid re-fetching the same directory (most commonly, when attempting to traverse up from root)
                return
            }
            activeProc?.terminate()
            activeProc = Process()
            activeProc.executableURL = Constants.adbURL
            let safePwd = pwd.replacingOccurrences(of: "\"", with: "\\\"") // in case the pwd has quotation marks in its name
            activeProc.arguments = ["shell", #"for f in "\#(safePwd)"/{.,}*; do if [[ -e "$f" ]]; then if [[ -d "$f" ]]; then echo -n "d"; else echo -n "f"; fi; busybox basename "$f"; fi; done"#]
            
            let pipe = Pipe()
            activeProc.standardOutput = pipe
            let pipeHandle = pipe.fileHandleForReading
            
            buffer = ""
            pipeHandle.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    self.buffer += line
                    let entities = self.buffer.split(separator: "\r\n")
                    if entities.count > 0 {
                        let validEntities: [Substring]
                        if self.buffer.count > 1 && self.buffer.lastIndex(of: "\r\n") == self.buffer.index(before: self.buffer.endIndex) {
                            // If we hit an update right at the end of a file (or it's the end of the list), we can do a complete sweep and flush the buffer
                            validEntities = entities
                            self.buffer = ""
                        } else {
                            // Updates will likely occur in the middle of a line/entity, so the last element of the buffer is still in progress if it doesn't have the correct terminator
                            validEntities = entities.dropLast()
                            self.buffer = String(entities.last ?? "")
                        }
                        DispatchQueue.main.async {
                            self.contents.append(contentsOf:
                                validEntities
                                    .filter { $0 != "d." && $0 != "d.." }
                                    .map { Entity(name: String($0.dropFirst()),
                                                  type: $0.first == "d" ? .directory : .file,
                                                  hidden: $0.dropFirst().first == ".") }
                            )
                        }
                    }
                } else {
                    print("Error decoding data: \(pipe.availableData)")
                }
            }
            
            contents = []
            do {
                try activeProc.run()
            } catch let e {
                print("Error running adb", e.localizedDescription, e)
                return
            }
        }
    }
    
    init() {
        pwd = Constants.homePath // since didSet doesn't get called on first init and the value needs to change to refresh (a bit hacky…)
    }
    
    func downloadFile(path: String) {
        let dlProc = Process()
        dlProc.executableURL = Constants.adbURL
        let dlDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].path
        guard dlDir != "" else {
            print("Could not find user Downloads directory")
            return
        }
        dlProc.arguments = ["pull", path, dlDir]
        dlProc.launch()
    }
}
