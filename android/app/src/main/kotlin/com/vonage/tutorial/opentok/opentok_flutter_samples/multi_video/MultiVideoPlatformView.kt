package com.vonage.tutorial.opentok.opentok_flutter_samples.multi_video

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class MultiVideoPlatformView(context: Context) : PlatformView {
    private val videoContainer: MultiVideoContainer = MultiVideoContainer(context)

    val mainContainer get() = videoContainer.mainContainer

    override fun getView(): View {
        return videoContainer
    }

    override fun dispose() {}
}