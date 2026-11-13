package com.sza.deviceinfo.ui.common.widget

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.drawable.InsetDrawable
import android.util.AttributeSet
import androidx.activity.ComponentActivity
import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.res.use
import com.google.android.material.appbar.MaterialToolbar
import com.sza.deviceinfo.R

/**
 * Standard toolbar with navigation and title icon support.
 */
class StandardToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = androidx.appcompat.R.attr.toolbarStyle,
) : MaterialToolbar(context, attrs, defStyleAttr) {

    init {
        context.obtainStyledAttributes(attrs, R.styleable.StandardToolbar, defStyleAttr, 0).use { typedArray ->
            val iconRes = typedArray.getResourceId(R.styleable.StandardToolbar_stbTitleIcon, 0)
            if (iconRes != 0) {
                applyTitleIcon(iconRes, typedArray.getColorStateList(R.styleable.StandardToolbar_stbTitleIconTint))
            }
        }
    }

    fun setUpNavigation(activity: ComponentActivity) {
        setNavigationOnClickListener { activity.onBackPressedDispatcher.onBackPressed() }
    }

    private fun applyTitleIcon(@DrawableRes iconRes: Int, tint: ColorStateList?) {
        val icon = AppCompatResources.getDrawable(context, iconRes)?.mutate() ?: return
        tint?.let { icon.setTintList(it) }
        val gap = resources.getDimensionPixelSize(R.dimen.toolbar_title_icon_gap)
        logo = InsetDrawable(icon, 0, 0, gap, 0)
    }
}
