
import Foundation

/// An object that holds 'Cancellable' objects internally and cancels them when released. Works serially
final class CancelationBag {
    private var tasks: [Cancellable] = []
    private let lock = NSLock()

    deinit {
        cancelAll()
    }

    func insert(_ task: Cancellable) {
        lock.lock()
        defer { lock.unlock() }
        tasks.append(task)
    }

    func cancelAll() {
        lock.lock()
        defer { lock.unlock() }
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
