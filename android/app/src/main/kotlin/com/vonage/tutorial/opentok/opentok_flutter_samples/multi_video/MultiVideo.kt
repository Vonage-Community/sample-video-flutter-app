package com.vonage.tutorial.opentok.opentok_flutter_samples.multi_video

import android.util.Log
import com.opentok.android.*
import com.vonage.tutorial.opentok.opentok_flutter_samples.MainActivity
import com.vonage.tutorial.opentok.opentok_flutter_samples.config.SdkState
import com.vonage.tutorial.opentok.opentok_flutter_samples.R

class MultiVideo(mainActivity: MainActivity) {

    private var session: Session? = null
    private var publisher: Publisher? = null
    private val subscribers = ArrayList<Subscriber>()
    private val subscriberStreams = HashMap<Stream, Subscriber>()

    private var activity: MainActivity? = null

    private lateinit var multiVideoPlatformView: MultiVideoPlatformView

    private val sessionListener: Session.SessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            // Connected to session
            Log.d("MainActivity", "Connected to session ${session.sessionId}")

            activity?.updateFlutterState(SdkState.loggedIn, activity!!.multiVideoMethodChannel)
            session.publish(publisher)
        }

        override fun onDisconnected(session: Session) {
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.multiVideoMethodChannel)
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamReceived: New Stream Received " + stream.streamId + " in session: " + session.sessionId
            )

            val subscriber = Subscriber.Builder(activity, stream).build()
            session.subscribe(subscriber)
            subscribers.add(subscriber)
            subscriberStreams[stream] = subscriber
            val subId = getResIdForSubscriberIndex(subscribers.size - 1)
            subscriber.view.id = subId
            multiVideoPlatformView.mainContainer.addView(subscriber.view)
            calculateLayout()
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            Log.d(
                "MainActivity",
                "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
            )

            val subscriber = subscriberStreams[stream] ?: return
            subscribers.remove(subscriber)
            subscriberStreams.remove(stream)
            multiVideoPlatformView.mainContainer.removeView(subscriber.view)

            // Recalculate view Ids
            for (i in subscribers.indices) {
                subscribers[i].view.id = getResIdForSubscriberIndex(i)
            }
            calculateLayout()
        }

        override fun onError(session: Session, opentokError: OpentokError) {
            Log.d("MainActivity", "Session error: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.multiVideoMethodChannel)
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
            activity?.updateFlutterState(SdkState.error, activity!!.multiVideoMethodChannel)
        }
    }

    init {
        activity = mainActivity
        multiVideoPlatformView = MultiVideoFactory.getViewInstance(activity)

    }

    fun initSession(apiKey: String, sessionId: String, token: String) {
        session = Session.Builder(activity, apiKey, sessionId).build()
        session?.setSessionListener(sessionListener)
        session?.connect(token)
        startPublisherPreview()
        publisher?.view?.id = R.id.publisher_view_id
        multiVideoPlatformView.mainContainer.addView(publisher?.view)
        calculateLayout()
    }

    private fun getResIdForSubscriberIndex(index: Int): Int {
        val arr = activity!!.resources.obtainTypedArray(R.array.subscriber_view_ids)
        val subId = arr.getResourceId(index, 0)
        arr.recycle()
        return subId
    }

    private fun startPublisherPreview() {
        publisher = Publisher.Builder(activity).build()
        publisher?.setPublisherListener(publisherListener)
        publisher?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)
    }

    private fun calculateLayout() {
        val set = ConstraintSetHelper(R.id.main_container)
        val size = subscribers.size
        if (size == 0) {
            // Publisher full screen
            set.layoutViewFullScreen(R.id.publisher_view_id)
        } else if (size == 1) {
            // Publisher
            // Subscriber
            set.layoutViewAboveView(R.id.publisher_view_id, getResIdForSubscriberIndex(0))
            set.layoutViewWithTopBound(R.id.publisher_view_id, R.id.main_container)
            set.layoutViewWithBottomBound(getResIdForSubscriberIndex(0), R.id.main_container)
            set.layoutViewAllContainerWide(R.id.publisher_view_id, R.id.main_container)
            set.layoutViewAllContainerWide(getResIdForSubscriberIndex(0), R.id.main_container)
            set.layoutViewHeightPercent(R.id.publisher_view_id, .5f)
            set.layoutViewHeightPercent(getResIdForSubscriberIndex(0), .5f)
        } else if (size > 1 && size % 2 == 0) {
            //  Publisher
            // Sub1 | Sub2
            // Sub3 | Sub4
            //    .....
            val rows = size / 2 + 1
            val heightPercent = 1f / rows
            set.layoutViewWithTopBound(R.id.publisher_view_id, R.id.main_container)
            set.layoutViewAllContainerWide(R.id.publisher_view_id, R.id.main_container)
            set.layoutViewHeightPercent(R.id.publisher_view_id, heightPercent)
            var i = 0

            while (i < size) {
                if (i == 0) {
                    set.layoutViewAboveView(R.id.publisher_view_id, getResIdForSubscriberIndex(i))
                    set.layoutViewAboveView(R.id.publisher_view_id, getResIdForSubscriberIndex(i + 1))
                } else {
                    set.layoutViewAboveView(getResIdForSubscriberIndex(i - 2), getResIdForSubscriberIndex(i))
                    set.layoutViewAboveView(getResIdForSubscriberIndex(i - 1), getResIdForSubscriberIndex(i + 1))
                }
                set.layoutTwoViewsOccupyingAllRow(getResIdForSubscriberIndex(i), getResIdForSubscriberIndex(i + 1))
                set.layoutViewHeightPercent(getResIdForSubscriberIndex(i), heightPercent)
                set.layoutViewHeightPercent(getResIdForSubscriberIndex(i + 1), heightPercent)
                i += 2
            }
            set.layoutViewWithBottomBound(getResIdForSubscriberIndex(size - 2), R.id.main_container)
            set.layoutViewWithBottomBound(getResIdForSubscriberIndex(size - 1), R.id.main_container)
        } else if (size > 1) {
            // Pub  | Sub1
            // Sub2 | Sub3
            // Sub3 | Sub4
            //    .....
            val rows = (size + 1) / 2
            val heightPercent = 1f / rows
            set.layoutViewWithTopBound(R.id.publisher_view_id, R.id.main_container)
            set.layoutViewHeightPercent(R.id.publisher_view_id, heightPercent)
            set.layoutViewWithTopBound(getResIdForSubscriberIndex(0), R.id.main_container)
            set.layoutViewHeightPercent(getResIdForSubscriberIndex(0), heightPercent)
            set.layoutTwoViewsOccupyingAllRow(R.id.publisher_view_id, getResIdForSubscriberIndex(0))
            var i = 1

            while (i < size) {
                if (i == 1) {
                    set.layoutViewAboveView(R.id.publisher_view_id, getResIdForSubscriberIndex(i))
                    set.layoutViewHeightPercent(R.id.publisher_view_id, heightPercent)
                    set.layoutViewAboveView(getResIdForSubscriberIndex(0), getResIdForSubscriberIndex(i + 1))
                    set.layoutViewHeightPercent(getResIdForSubscriberIndex(0), heightPercent)
                } else {
                    set.layoutViewAboveView(getResIdForSubscriberIndex(i - 2), getResIdForSubscriberIndex(i))
                    set.layoutViewHeightPercent(getResIdForSubscriberIndex(i - 2), heightPercent)
                    set.layoutViewAboveView(getResIdForSubscriberIndex(i - 1), getResIdForSubscriberIndex(i + 1))
                    set.layoutViewHeightPercent(getResIdForSubscriberIndex(i - 1), heightPercent)
                }
                set.layoutTwoViewsOccupyingAllRow(getResIdForSubscriberIndex(i), getResIdForSubscriberIndex(i + 1))
                i += 2
            }
            set.layoutViewWithBottomBound(getResIdForSubscriberIndex(size - 2), R.id.main_container)
            set.layoutViewWithBottomBound(getResIdForSubscriberIndex(size - 1), R.id.main_container)
        }
        set.applyToLayout(multiVideoPlatformView.mainContainer, true)
    }
}