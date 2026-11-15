package com.sza.deviceinfo.ui

import org.junit.Test

class PhoneUiSizingResourcesTest {
    @Test
    fun `phone resource targets meet the ordinary touch baseline`() {
        PhoneUiSizingResources.verify()
    }
}
