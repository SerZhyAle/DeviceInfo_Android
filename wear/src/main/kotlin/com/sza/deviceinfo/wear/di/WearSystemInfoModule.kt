package com.sza.deviceinfo.wear.di

import com.google.gson.Gson
import com.sza.deviceinfo.wear.data.wear.AndroidWearEnvironmentDataSource
import com.sza.deviceinfo.wear.data.wear.AndroidWearHardwareDataSource
import com.sza.deviceinfo.wear.data.wear.AndroidWearHealthDataSource
import com.sza.deviceinfo.wear.data.wear.AndroidWearSystemInfoDataSource
import com.sza.deviceinfo.wear.data.wear.AndroidWearSystemInfoReportSender
import com.sza.deviceinfo.wear.domain.repository.WearEnvironmentDataSource
import com.sza.deviceinfo.wear.domain.repository.WearHardwareDataSource
import com.sza.deviceinfo.wear.domain.repository.WearHealthDataSource
import com.sza.deviceinfo.wear.domain.repository.WearSystemInfoDataSource
import com.sza.deviceinfo.wear.domain.repository.WearSystemInfoReportSender
import com.sza.deviceinfo.wear.domain.systeminfo.AppInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.DeviceInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.EnvironmentInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.HealthInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.MemoryInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.PhoneLinkContributor
import com.sza.deviceinfo.wear.domain.systeminfo.RadioCapabilityContributor
import com.sza.deviceinfo.wear.domain.systeminfo.SensorsInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.StorageInfoContributor
import com.sza.deviceinfo.wear.domain.systeminfo.WearSystemInfoContributor
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import dagger.multibindings.Multibinds
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class WearSystemInfoModule {

    @Multibinds
    abstract fun systemInfoContributors(): Set<@JvmSuppressWildcards WearSystemInfoContributor>

    @Binds
    @IntoSet
    abstract fun bindDeviceInfoContributor(impl: DeviceInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindAppInfoContributor(impl: AppInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindHealthInfoContributor(impl: HealthInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindSensorsInfoContributor(impl: SensorsInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindEnvironmentInfoContributor(
        impl: EnvironmentInfoContributor
    ): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindRadioCapabilityContributor(
        impl: RadioCapabilityContributor
    ): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindMemoryInfoContributor(impl: MemoryInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindStorageInfoContributor(impl: StorageInfoContributor): WearSystemInfoContributor

    @Binds
    @IntoSet
    abstract fun bindPhoneLinkContributor(impl: PhoneLinkContributor): WearSystemInfoContributor

    @Binds
    @Singleton
    abstract fun bindWearSystemInfoDataSource(
        impl: AndroidWearSystemInfoDataSource
    ): WearSystemInfoDataSource

    @Binds
    @Singleton
    abstract fun bindWearHardwareDataSource(
        impl: AndroidWearHardwareDataSource
    ): WearHardwareDataSource

    @Binds
    @Singleton
    abstract fun bindWearHealthDataSource(
        impl: AndroidWearHealthDataSource
    ): WearHealthDataSource

    @Binds
    @Singleton
    abstract fun bindWearEnvironmentDataSource(
        impl: AndroidWearEnvironmentDataSource
    ): WearEnvironmentDataSource

    @Binds
    abstract fun bindSystemInfoReportSender(
        impl: AndroidWearSystemInfoReportSender
    ): WearSystemInfoReportSender

    companion object {
        @Provides
        @Singleton
        fun provideGson(): Gson = Gson()
    }
}
