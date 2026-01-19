package com.jetbrains.kmpapp

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.viewmodel.CreationExtras
import kotlinx.cinterop.BetaInteropApi
import kotlinx.cinterop.ObjCClass

@OptIn(BetaInteropApi::class)
@Throws(IllegalArgumentException::class)
fun ViewModelStore.resolveViewModel(
    modelClass: ObjCClass,
    factory: ViewModelProvider.Factory,
    key: String? = null,
    extras: CreationExtras = CreationExtras.Empty,
): ViewModel {
    val className = modelClass.toString()
    val resolvedKey = key ?: "androidx.lifecycle.ViewModelProvider.DefaultKey:$className"

    var viewModel = get(resolvedKey)
    if (viewModel == null) {
        viewModel = factory.create(ViewModel::class, extras)
        put(resolvedKey, viewModel)
    }

    return viewModel
}
