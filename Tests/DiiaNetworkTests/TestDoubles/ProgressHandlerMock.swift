
import Foundation
import DiiaNetwork

class ProgressHandlerMock: ProgressHandler {
    var onShowProgress: (() -> Void)?
    var onHideProgress: (() -> Void)?

    func showProgress() {
        onShowProgress?()
    }

    func hideProgress() {
        onHideProgress?()
    }
}
