package com.sza.deviceinfo.di

import com.google.gson.Gson
import com.sza.deviceinfo.data.local.preferences.NotificationPromptStore
import com.sza.deviceinfo.data.local.preferences.SharedPreferencesNotificationPromptStore
import com.sza.deviceinfo.data.repository.DischargeRateBatteryRuntimeEstimator
import com.sza.deviceinfo.data.repository.SystemInfoGroupStateRepositoryImpl
import com.sza.deviceinfo.data.wear.WearableDataLayerRepositoryImpl
import com.sza.deviceinfo.domain.repository.BatteryRuntimeEstimator
import com.sza.deviceinfo.domain.repository.SystemInfoGroupStateRepository
import com.sza.deviceinfo.domain.repository.WearableDataLayerRepository
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import javax.inject.Qualifier
import javax.inject.Singleton

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class IoDispatcher

/** Binds the remembered expanded state repository and coroutine dispatchers for System info. */
@Module
@InstallIn(SingletonComponent::class)
abstract class SystemInfoModule {

    @Binds
    @Singleton
    abstract fun bindSystemInfoGroupStateRepository(
        impl: SystemInfoGroupStateRepositoryImpl,
    ): SystemInfoGroupStateRepository

    @Binds
    @Singleton
    abstract fun bindWearableDataLayerRepository(
        impl: WearableDataLayerRepositoryImpl,
    ): WearableDataLayerRepository

    @Binds
    @Singleton
    abstract fun bindBatteryRuntimeEstimator(
        impl: DischargeRateBatteryRuntimeEstimator,
    ): BatteryRuntimeEstimator

    @Binds
    @Singleton
    abstract fun bindNotificationPromptStore(
        impl: SharedPreferencesNotificationPromptStore,
    ): NotificationPromptStore

    companion object {
        @Provides
        @Singleton
        @IoDispatcher
        fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO

        @Provides
        @Singleton
        fun provideGson(): Gson = Gson()
    }
}
