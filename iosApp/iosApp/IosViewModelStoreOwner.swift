import Foundation
import SwiftUI
import Shared

final class IosViewModelStoreOwner: ObservableObject {
    let viewModelStore = ViewModelStore()

    func viewModel<VM: ViewModel>(factory: @escaping () -> VM) -> VM {
        return viewModelStore.resolveViewModel(objCClass: VM.self, factory: factory) as! VM
    }

    deinit {
        viewModelStore.clear()
    }
}
