package com.vonage.tutorial.opentok.opentok_flutter_samples.one_to_one_video

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class OpentokVideoFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private lateinit var view: OpentokVideoPlatformView

        fun getViewInstance(context: Context?): OpentokVideoPlatformView {
            if(!this::view.isInitialized) {
                view = context?.let { OpentokVideoPlatformView(it) }!!
            }

            return view
        }
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return getViewInstance(context)
    }
}