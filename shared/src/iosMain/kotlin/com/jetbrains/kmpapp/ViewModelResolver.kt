package com.jetbrains.kmpapp

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelStore

@Suppress("UNCHECKED_CAST")
fun <VM : ViewModel> ViewModelStore.resolveViewModel(
    objCClass: Any,
    factory: () -> VM
): VM {
    val className = objCClass.toString()
    val key = "androidx.lifecycle.ViewModelProvider.DefaultKey:$className"

    var viewModel = get(key)
    if (viewModel == null) {
        viewModel = factory()
        put(key, viewModel)
    }

    return viewModel as VM
}
