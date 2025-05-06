
import Foundation
import ReactiveKit

public protocol ProgressHandler: AnyObject {
    func showProgress()
    func hideProgress()
}

extension Signal {
    public func progress(start: @escaping () -> Void, end: @escaping () -> Void) -> Signal<Element, Error> {
        return Signal { observer in
            start()
            let disposable = self.observe { event in
                end()
                switch event {
                case .next(let value):
                    observer.receive(value)
                case .failed(let error):
                    observer.receive(completion: .failure(error))
                case .completed:
                    observer.receive(completion: .finished)
                }
            }
            return BlockDisposable {
                end()
                disposable.dispose()
            }
        }
    }

    public func processError(handler: @escaping (Error) -> Void) -> SafeSignal<Element> {
        return SafeSignal { observer in
            let disposable = self.observe { event in
                switch event {
                case .next(let value):
                    observer.receive(value)
                case .failed(let error):
                    handler(error)
                case .completed:
                    observer.receive(completion: .finished)
                }
            }
            return BlockDisposable {
                disposable.dispose()
            }
        }
    }
}
