package com.vonage.tutorial.opentok.opentok_flutter_samples.screen_sharing

import android.util.Log
import android.view.View
import android.webkit.WebSettings
import android.webkit.WebViewClient
import com.opentok.android.*
import com.vonage.tutorial.opentok.opentok_flutter_samples.MainActivity
import com.vonage.tutorial.opentok.opentok_flutter_samples.config.SdkState


class ScreenSharing(mainActivity: MainActivity) {

    private var session: Session? = null
    private var publisher: Publisher? = null

    private var activity: MainActivity? = null

    private lateinit var screenSharingPlatformView: ScreenSharingPlatformView

    private val sessionListener: Session.SessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            // Connected to session
            Log.d("MainActivity", "Connected to session ${session.sessionId}")


            val screenSharingCapturer = ScreenSharingCapturer(activity!!, screenSharingPlatformView.webView)

            publisher = Publisher.Builder(activity).capturer(screenSharingCapturer).build().apply {
                setPublisherListener(publisherListener)
                publisherVideoType = PublisherKit.PublisherKitVideoType.PublisherKitVideoTypeScreen
                audioFallbackEnabled = false
                val webview = screenSharingPlatformView.webView
                webview.webViewClient = WebViewClient()
                val webSettings: WebSettings = webview.settings
                webSettings.javaScriptEnabled = true
                webview.setLayerType(View.LAYER_TYPE_SOFTWARE, null)
                webview.loadUrl("https://www.tokbox.com")

                renderer?.setStyle(
                    BaseVideoRenderer.STYLE_VIDEO_SCALE,
                    BaseVideoRenderer.STYLE_VIDEO_FILL
                )

                screenSharingPlatformView.publisherContainer.addView(view)
            }

            activity?.updateFlutterState(SdkState.loggedIn, activity!!.screenSharingMethodChannel)
            session.publish(publisher)
        }

        override fun onDisconnected(session: Session) {
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.screenSharingMethodChannel)
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamReceived: New Stream Received " + stream.streamId + " in session: " + session.sessionId
            )
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
            )
        }

        override fun onError(session: Session, opentokError: OpentokError) {
            Log.d("MainActivity", "Session error: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.screenSharingMethodChannel)
        }
    }

    private val publisherListener: PublisherKit.PublisherListener = object :
        PublisherKit.PublisherListener {
        override fun onStreamCreated(publisherKit: PublisherKit, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamCreated: Publisher Stream Created. Own stream " + stream.streamId
            )
        }

        override fun onStreamDestroyed(publisherKit: PublisherKit, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamDestroyed: Publisher Stream Destroyed. Own stream " + stream.streamId
            )
        }

        override fun onError(publisherKit: PublisherKit, opentokError: OpentokError) {
            Log.d("MainActivity", "PublisherKit onError: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.screenSharingMethodChannel)
        }
    }

    init {
        activity = mainActivity
        screenSharingPlatformView = ScreenSharingFactory.getViewInstance(activity)
    }

    fun initSession(apiKey: String, sessionId: String, token: String) {
        session = Session.Builder(activity, apiKey, sessionId).build()
        session?.setSessionListener(sessionListener)
        session?.connect(token)
    }
}