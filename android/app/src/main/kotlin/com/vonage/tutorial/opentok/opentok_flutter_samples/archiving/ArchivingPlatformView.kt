package com.vonage.tutorial.opentok.opentok_flutter_samples.archiving

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class ArchivingPlatformView(context: Context) : PlatformView {
    private val videoContainer: ArchivingContainer = ArchivingContainer(context)

    val subscriberContainer get() = videoContainer.subscriberContainer
    val publisherContainer get() = videoContainer.publisherContainer

    override fun getView(): View {
        return videoContainer
    }

    override fun dispose() {}
}