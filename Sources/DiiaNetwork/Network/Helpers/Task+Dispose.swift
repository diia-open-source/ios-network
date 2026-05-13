
import Foundation

extension Task<Void, Never> {
    func dispose(in bag: CancelationBag) {
        bag.insert(self)
    }
}
