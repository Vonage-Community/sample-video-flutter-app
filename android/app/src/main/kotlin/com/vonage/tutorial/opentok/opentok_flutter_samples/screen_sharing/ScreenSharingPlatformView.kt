package com.vonage.tutorial.opentok.opentok_flutter_samples.screen_sharing

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class ScreenSharingPlatformView(context: Context) : PlatformView {
    private val screenSharingContainer: ScreenSharingContainer = ScreenSharingContainer(context)

    val publisherContainer get() = screenSharingContainer.publisherContainer
    val webView get() = screenSharingContainer.webview

    override fun getView(): View {
        return screenSharingContainer
    }

    override fun dispose() {}
}