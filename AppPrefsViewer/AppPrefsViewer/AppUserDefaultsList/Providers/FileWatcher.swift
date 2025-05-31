//
//  FileWatcher.swift
//  FileWatcher
//
//  Created by Vladimir Nikitin on 31.05.2025.
//

import Foundation

/// A lightweight file system watcher that monitors a file for write events.
/// Automatically handles setup and teardown of the underlying file descriptor.
final class FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt = -1

    /// Starts watching a file for `.write` events.
    /// - Parameters:
    ///   - url: The file URL to watch (must point to a valid file on disk).
    ///   - onChange: A closure executed on the main thread when the file changes.
    func watch(url: URL, onChange: @escaping () -> Void) {
        // Stop any previous observation before starting a new one
        stop()

        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("❌ Failed to open file for observation: \(url.path)")
            return
        }

        let queue = DispatchQueue.global()
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: queue
        )

        source?.setEventHandler {
            DispatchQueue.main.async {
                onChange()
            }
        }

        source?.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd != -1 {
                close(fd)
            }
            self?.fileDescriptor = -1
            self?.source = nil
        }

        source?.resume()
    }

    /// Stops watching the file and releases system resources.
    func stop() {
        source?.cancel()
        source = nil
    }

    deinit {
        stop()
    }
}
