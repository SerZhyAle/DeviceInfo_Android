package com.sza.deviceinfo.ui.common.widget

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.core.content.res.use
import androidx.core.view.updateLayoutParams
import androidx.core.view.updatePadding
import com.sza.deviceinfo.R

/**
 * Reusable header for collapsible sections and group tiles.
 *
 * Owns only its visual expanded state and notifies callers when clicked.
 */
class CollapsibleSectionHeader @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : LinearLayout(context, attrs, defStyleAttr) {

    private val headerRow: LinearLayout
    private val chevronView: ImageView
    private val iconView: ImageView
    private val titleView: TextView
    private val summaryView: TextView
    private val trailingSlot: FrameLayout

    private var expanded = false
    private var titleText: CharSequence = ""
    private var summaryText: CharSequence? = null
    private var expandedChangeListener: ((Boolean) -> Unit)? = null

    init {
        orientation = VERTICAL
        LayoutInflater.from(context).inflate(R.layout.view_collapsible_section_header, this, true)

        headerRow = findViewById(R.id.csh_headerRow)
        chevronView = findViewById(R.id.csh_chevron)
        iconView = findViewById(R.id.csh_icon)
        titleView = findViewById(R.id.csh_title)
        summaryView = findViewById(R.id.csh_summary)
        trailingSlot = findViewById(R.id.csh_trailingSlot)

        headerRow.setOnClickListener {
            setExpanded(!expanded, notify = true)
        }

        attrs?.let { applyAttributes(it, defStyleAttr) }
        updateChevron(animate = false)
    }

    private fun applyAttributes(attrs: AttributeSet, defStyleAttr: Int) {
        context.obtainStyledAttributes(attrs, R.styleable.CollapsibleSectionHeader, defStyleAttr, 0).use { a ->
            a.getText(R.styleable.CollapsibleSectionHeader_cshTitle)?.let { setTitle(it) }
            a.getText(R.styleable.CollapsibleSectionHeader_cshSummary)?.let { setSummary(it) }
            val iconRes = a.getResourceId(R.styleable.CollapsibleSectionHeader_cshIcon, 0)
            if (iconRes != 0) setIcon(iconRes)
            val isExp = a.getBoolean(R.styleable.CollapsibleSectionHeader_cshExpanded, false)
            setExpanded(isExp, notify = false)
        }
    }

    fun setTitle(text: CharSequence) {
        titleText = text
        titleView.text = text
    }

    fun setTitle(@StringRes resId: Int) {
        setTitle(context.getText(resId))
    }

    fun setSummary(text: CharSequence?) {
        summaryText = text
        if (text.isNullOrBlank()) {
            summaryView.text = ""
            summaryView.visibility = View.GONE
        } else {
            summaryView.text = text
            summaryView.visibility = View.VISIBLE
        }
    }

    fun setSummary(@StringRes resId: Int) {
        setSummary(context.getText(resId))
    }

    fun setIcon(icon: Drawable?) {
        iconView.setImageDrawable(icon)
        iconView.visibility = if (icon == null) View.GONE else View.VISIBLE
    }

    fun setIcon(@DrawableRes resId: Int) {
        iconView.setImageResource(resId)
        iconView.visibility = View.VISIBLE
    }

    fun setExpanded(expanded: Boolean, notify: Boolean = true) {
        if (this.expanded == expanded) return
        this.expanded = expanded
        updateChevron(animate = notify)
        if (notify) {
            expandedChangeListener?.invoke(expanded)
        }
    }

    fun isExpanded(): Boolean = expanded

    fun setOnExpandedChangeListener(listener: (Boolean) -> Unit) {
        this.expandedChangeListener = listener
    }

    fun setTrailingControl(view: View) {
        trailingSlot.removeAllViews()
        trailingSlot.addView(view)
        trailingSlot.visibility = View.VISIBLE
    }

    fun setHeaderPadding(horizontal: Int, vertical: Int) {
        headerRow.updatePadding(left = horizontal, right = horizontal, top = vertical, bottom = vertical)
    }

    fun setLeadingSpacing(spacing: Int) {
        chevronView.updateLayoutParams<MarginLayoutParams> {
            marginEnd = spacing
        }
    }

    fun setTitleTextSizePx(sizePx: Float) {
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_PX, sizePx)
    }

    fun setTitleBreakStrategy(strategy: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            titleView.breakStrategy = strategy
        }
    }

    private fun updateChevron(animate: Boolean) {
        val targetRotation = if (expanded) 180f else 0f
        if (animate) {
            chevronView.animate().rotation(targetRotation).setDuration(150).start()
        } else {
            chevronView.rotation = targetRotation
        }
    }
}
