
import Foundation
import DiiaNetwork

final class ProgressHandlerMock: ProgressHandler {
    var onShowProgress: ((Bool) -> Void)?
    var onHideProgress: ((Bool) -> Void)?

    func showProgress() {
        onShowProgress?(true)
    }

    func hideProgress() {
        onHideProgress?(true)
    }
}
