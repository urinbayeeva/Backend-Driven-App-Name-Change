package com.example.brandswitcher

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Switches the launcher name and icon by enabling one activity-alias per
 * name x icon pair. Calls from Flutter are staged and applied in onStop,
 * so the launcher never redraws while the app is in the foreground.
 */
class BrandSwitcher(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        // Append-only; must match the aliases in AndroidManifest.xml,
        // the Gradle registry and lib/features/brand/domain/brand_catalog.dart.
        val NAMES = listOf("aurora", "nova", "pulse", "orbit")
        val ICONS = listOf("rocket", "star", "heart")

        // Class names come from the Kotlin namespace, not applicationId,
        // so flavors with applicationIdSuffix still resolve.
        private const val NAMESPACE = "com.example.brandswitcher"

        fun aliasClass(name: String, icon: String) =
            "$NAMESPACE.Alias${name.cap()}${icon.cap()}"

        /** Notification small icon that follows the launcher icon. */
        fun notificationIcon(icon: String) = when (icon) {
            "star" -> R.drawable.ic_notif_star
            "heart" -> R.drawable.ic_notif_heart
            else -> R.drawable.ic_notif_rocket
        }

        private fun String.cap() = replaceFirstChar { it.uppercase() }
    }

    private val pm = context.packageManager
    private val prefs = context.getSharedPreferences("brand", Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setNameKey" -> stage("pending_name", call.argument("key"), NAMES, result)
            "setIconKey" -> stage("pending_icon", call.argument("key"), ICONS, result)
            "currentNameKey" -> result.success(current().first)
            "currentIconKey" -> result.success(current().second)
            "reconcile" -> {
                val name = call.argument<String>("activeName")
                val icon = call.argument<String>("activeIcon")
                if (name == null || icon == null) {
                    result.error("BAD_ARGS", null, null)
                } else {
                    prefs.edit().putString("pending_reconcile", "$name:$icon").apply()
                    result.success(true)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun stage(pref: String, key: String?, allowed: List<String>, result: MethodChannel.Result) {
        if (key == null || key !in allowed) {
            result.error("UNKNOWN_KEY", key, null)
            return
        }
        prefs.edit().putString(pref, key).apply()
        result.success(true)
    }

    /** Called from MainActivity.onStop. */
    fun applyPending() {
        prefs.getString("pending_reconcile", null)?.let {
            val (name, icon) = it.split(":", limit = 2)
            reconcile(name, icon)
            prefs.edit().remove("pending_reconcile").apply()
        }
        val name = prefs.getString("pending_name", null)
        val icon = prefs.getString("pending_icon", null)
        if (name == null && icon == null) return
        val (curName, curIcon) = current()
        applyAlias(name ?: curName, icon ?: curIcon)
        prefs.edit().remove("pending_name").remove("pending_icon").apply()
    }

    private fun applyAlias(name: String, icon: String) {
        if (current() == name to icon) return
        val target = aliasClass(name, icon)
        // Enable the new alias first; the reverse order leaves the launcher empty.
        setState(target, PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
        allAliases().filter { it != target }.forEach {
            setState(it, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        }
    }

    // After an update whose primary pair equals the active pair, drop all
    // runtime overrides. The effective state is unchanged, so the launcher
    // does not redraw and the home screen shortcut is kept.
    private fun reconcile(activeName: String, activeIcon: String) {
        if (activeName != BuildConfig.PRIMARY_BRAND || activeIcon != BuildConfig.PRIMARY_ICON) return
        allAliases().forEach { setState(it, PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) }
    }

    private fun current(): Pair<String, String> {
        for (n in NAMES) for (i in ICONS) {
            if (isEnabled(aliasClass(n, i))) return n to i
        }
        return BuildConfig.PRIMARY_BRAND to BuildConfig.PRIMARY_ICON
    }

    // Effective state: runtime override, otherwise the manifest default.
    @Suppress("DEPRECATION")
    private fun isEnabled(cls: String): Boolean {
        val cn = ComponentName(context.packageName, cls)
        return when (pm.getComponentEnabledSetting(cn)) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> false
            else -> pm.getActivityInfo(cn, PackageManager.MATCH_DISABLED_COMPONENTS).enabled
        }
    }

    private fun allAliases() = NAMES.flatMap { n -> ICONS.map { i -> aliasClass(n, i) } }

    private fun setState(cls: String, state: Int) = pm.setComponentEnabledSetting(
        ComponentName(context.packageName, cls), state, PackageManager.DONT_KILL_APP,
    )
}
