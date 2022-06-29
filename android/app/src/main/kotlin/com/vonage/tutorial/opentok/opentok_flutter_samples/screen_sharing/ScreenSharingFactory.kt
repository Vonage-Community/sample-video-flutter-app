package com.vonage.tutorial.opentok.opentok_flutter_samples.screen_sharing

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ScreenSharingFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private lateinit var view: ScreenSharingPlatformView

        fun getViewInstance(context: Context?): ScreenSharingPlatformView {
            if(!this::view.isInitialized) {
                view = context?.let { ScreenSharingPlatformView(it) }!!
            }

            return view
        }
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return getViewInstance(context)
    }
}