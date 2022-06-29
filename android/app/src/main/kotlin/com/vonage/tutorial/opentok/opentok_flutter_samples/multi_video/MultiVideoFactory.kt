package com.vonage.tutorial.opentok.opentok_flutter_samples.multi_video

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MultiVideoFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private lateinit var view: MultiVideoPlatformView

        fun getViewInstance(context: Context?): MultiVideoPlatformView {
            if(!this::view.isInitialized) {
                view = context?.let { MultiVideoPlatformView(it) }!!
            }

            return view
        }
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return getViewInstance(context)
    }
}