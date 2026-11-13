package com.sza.deviceinfo.di

import com.sza.deviceinfo.core.systeminfo.ExtendedDiagnosticsContributor
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.Multibinds

/**
 * Declares the multibound set of [ExtendedDiagnosticsContributor]s so it is injectable even when no
 * build contributes one (the `store` flavor injects an empty set). A real contributor is bound `@IntoSet`
 * by the module of the build that carries it: `RestrictedExtendedDiagnosticsModule` in `src/restricted`.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class ExtendedDiagnosticsModule {

    @Multibinds
    abstract fun extendedDiagnosticsContributors(): Set<@JvmSuppressWildcards ExtendedDiagnosticsContributor>
}
