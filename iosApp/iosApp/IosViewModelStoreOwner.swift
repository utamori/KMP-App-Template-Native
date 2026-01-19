import Foundation
import SwiftUI
import Shared

final class IosViewModelStoreOwner: ObservableObject {
    let viewModelStore = ViewModelStore()

    func viewModel<T: ViewModel>(
        key: String? = nil,
        factory: ViewModelProviderFactory,
        extras: CreationExtras? = nil
    ) -> T {
        return try! viewModelStore.resolveViewModel(
            modelClass: T.self,
            factory: factory,
            key: key,
            extras: extras ?? CreationExtras.Empty.shared
        ) as! T
    }

    deinit {
        viewModelStore.clear()
    }
}
