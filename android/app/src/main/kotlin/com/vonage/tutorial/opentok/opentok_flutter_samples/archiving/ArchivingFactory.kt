package com.vonage.tutorial.opentok.opentok_flutter_samples.archiving

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ArchivingFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private lateinit var view: ArchivingPlatformView

        fun getViewInstance(context: Context?): ArchivingPlatformView {
            if (!this::view.isInitialized) {
                view = context?.let { ArchivingPlatformView(it) }!!
            }

            return view
        }
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return getViewInstance(context)
    }
}