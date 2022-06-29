package com.vonage.tutorial.opentok.opentok_flutter_samples.one_to_one_video

import android.opengl.GLSurfaceView
import android.util.Log
import com.opentok.android.*
import com.vonage.tutorial.opentok.opentok_flutter_samples.MainActivity
import com.vonage.tutorial.opentok.opentok_flutter_samples.config.SdkState

class OneToOneVideo(mainActivity: MainActivity) {

    private var session: Session? = null
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null

    private var activity: MainActivity? = null

    private lateinit var opentokVideoPlatformView: OpentokVideoPlatformView

    private val sessionListener: Session.SessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            // Connected to session
            Log.d("MainActivity", "Connected to session ${session.sessionId}")

            publisher = Publisher.Builder(activity).build().apply {
                setPublisherListener(publisherListener)
                renderer?.setStyle(
                    BaseVideoRenderer.STYLE_VIDEO_SCALE,
                    BaseVideoRenderer.STYLE_VIDEO_FILL
                )

                opentokVideoPlatformView.publisherContainer.addView(view)
                if (view is GLSurfaceView) {
                    (view as GLSurfaceView).setZOrderOnTop(true)
                }
            }

            activity?.updateFlutterState(SdkState.loggedIn, activity!!.oneToOneVideoMethodChannel)
            session.publish(publisher)
        }

        override fun onDisconnected(session: Session) {
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.oneToOneVideoMethodChannel)
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamReceived: New Stream Received " + stream.streamId + " in session: " + session.sessionId
            )
            if (subscriber == null) {
                subscriber = Subscriber.Builder(activity, stream).build().apply {
                    renderer?.setStyle(
                        BaseVideoRenderer.STYLE_VIDEO_SCALE,
                        BaseVideoRenderer.STYLE_VIDEO_FILL
                    )
                    setSubscriberListener(subscriberListener)
                    session.subscribe(this)

                    opentokVideoPlatformView.subscriberContainer.addView(view)
                }
            }
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
            )

            if (subscriber != null) {
                subscriber = null

                opentokVideoPlatformView.subscriberContainer.removeAllViews()
            }
        }

        override fun onError(session: Session, opentokError: OpentokError) {
            Log.d("MainActivity", "Session error: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.oneToOneVideoMethodChannel)
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
            activity?.updateFlutterState(SdkState.error, activity!!.oneToOneVideoMethodChannel)
        }
    }

    var subscriberListener: SubscriberKit.SubscriberListener = object :
        SubscriberKit.SubscriberListener {
        override fun onConnected(subscriberKit: SubscriberKit) {
            Log.d(
                "MainActivity",
                "onConnected: Subscriber connected. Stream: " + subscriberKit.stream.streamId
            )
        }

        override fun onDisconnected(subscriberKit: SubscriberKit) {
            Log.d(
                "MainActivity",
                "onDisconnected: Subscriber disconnected. Stream: " + subscriberKit.stream.streamId
            )
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.oneToOneVideoMethodChannel)
        }

        override fun onError(subscriberKit: SubscriberKit, opentokError: OpentokError) {
            Log.d("MainActivity", "SubscriberKit onError: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.oneToOneVideoMethodChannel)
        }
    }

    init {
        activity = mainActivity
        opentokVideoPlatformView = OpentokVideoFactory.getViewInstance(activity)
    }

    fun initSession(apiKey: String, sessionId: String, token: String) {
        session = Session.Builder(activity, apiKey, sessionId).build()
        session?.setSessionListener(sessionListener)
        session?.connect(token)
    }

    fun swapCamera() {
        publisher?.cycleCamera()
    }

    fun toggleAudio(publishAudio: Boolean) {
        publisher?.publishAudio = publishAudio
    }

    fun toggleVideo(publishVideo: Boolean) {
        publisher?.publishVideo = publishVideo
    }
}