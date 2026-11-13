package com.sza.deviceinfo.di

import com.sza.deviceinfo.core.systeminfo.ExtendedDiagnosticsContributor
import com.sza.deviceinfo.diagnostics.RestrictedExtendedDiagnosticsContributor
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet

/**
 * Binds the restricted build's extended-diagnostics contributor into the multibound set declared by
 * `ExtendedDiagnosticsModule` in `src/main`. Compiled only into the `restricted` flavor.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RestrictedExtendedDiagnosticsModule {

    @Binds
    @IntoSet
    abstract fun bindExtendedDiagnosticsContributor(
        impl: RestrictedExtendedDiagnosticsContributor,
    ): ExtendedDiagnosticsContributor
}
