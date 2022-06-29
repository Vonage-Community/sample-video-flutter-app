package com.vonage.tutorial.opentok.opentok_flutter_samples.archiving

import android.content.Intent
import android.net.Uri
import android.opengl.GLSurfaceView
import android.util.Log
import com.opentok.android.*
import com.vonage.tutorial.opentok.opentok_flutter_samples.MainActivity
import com.vonage.tutorial.opentok.opentok_flutter_samples.archiving.networking.APIService
import com.vonage.tutorial.opentok.opentok_flutter_samples.archiving.networking.EmptyCallback
import com.vonage.tutorial.opentok.opentok_flutter_samples.archiving.networking.GetSessionResponse
import com.vonage.tutorial.opentok.opentok_flutter_samples.archiving.networking.StartArchiveRequest
import com.vonage.tutorial.opentok.opentok_flutter_samples.config.SdkState
import com.vonage.tutorial.opentok.opentok_flutter_samples.config.ServerConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory

import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class Archiving(mainActivity: MainActivity) {
    private lateinit var retrofit: Retrofit
    private lateinit var apiService: APIService

    private var session: Session? = null
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null

    private var sessionId: String? = null
    private var currentArchiveId: String? = null
    private var playableArchiveId: String? = null

    private var activity: MainActivity? = null

    private lateinit var archivingPlatformView: ArchivingPlatformView

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

                archivingPlatformView.publisherContainer.addView(view)
                if (view is GLSurfaceView) {
                    (view as GLSurfaceView).setZOrderOnTop(true)
                }
            }

            activity?.updateFlutterState(SdkState.loggedIn, activity!!.archivingMethodChannel)
            session.publish(publisher)
        }

        override fun onDisconnected(session: Session) {
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.archivingMethodChannel)
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

                    archivingPlatformView.subscriberContainer.addView(view)
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

                archivingPlatformView.subscriberContainer.removeAllViews()
            }
        }

        override fun onError(session: Session, opentokError: OpentokError) {
            Log.d("MainActivity", "Session error: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.archivingMethodChannel)
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
            activity?.updateFlutterState(SdkState.error, activity!!.archivingMethodChannel)
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
            activity?.updateFlutterState(SdkState.loggedOut, activity!!.archivingMethodChannel)
        }

        override fun onError(subscriberKit: SubscriberKit, opentokError: OpentokError) {
            Log.d("MainActivity", "SubscriberKit onError: " + opentokError.message)
            activity?.updateFlutterState(SdkState.error, activity!!.archivingMethodChannel)
        }
    }

    private val archiveListener: Session.ArchiveListener = object : Session.ArchiveListener {
        override fun onArchiveStarted(session: Session, archiveId: String, archiveName: String) {
            currentArchiveId = archiveId
            activity?.updateFlutterArchiving(true, activity!!.archivingMethodChannel)
        }

        override fun onArchiveStopped(session: Session, archiveId: String) {
            playableArchiveId = archiveId
            currentArchiveId = null
            activity?.updateFlutterArchiving(false, activity!!.archivingMethodChannel)
        }
    }

    init {
        activity = mainActivity
        archivingPlatformView = ArchivingFactory.getViewInstance(activity)
    }

    fun initSession(apiKey: String, sessionId: String, token: String) {
        session = Session.Builder(activity, apiKey, sessionId).build()
        session?.setSessionListener(sessionListener)
        session?.setArchiveListener(archiveListener)
        session?.connect(token)

        initRetrofit()
    }

    private fun initRetrofit() {
        val logging = HttpLoggingInterceptor()
        logging.setLevel(HttpLoggingInterceptor.Level.BODY)
        val client: OkHttpClient = OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()

        retrofit = Retrofit.Builder()
            .baseUrl(ServerConfig.CHAT_SERVER_URL)
            .addConverterFactory(MoshiConverterFactory.create())
            .client(client)
            .build()

        apiService = retrofit.create(APIService::class.java)
    }

    fun getSession() {
        apiService.session?.enqueue(object : Callback<GetSessionResponse?> {
            override fun onResponse(call: Call<GetSessionResponse?>, response: Response<GetSessionResponse?>) {
                response.body()?.also {
                    initSession(it.apiKey, it.sessionId, it.token)
                }
            }

            override fun onFailure(call: Call<GetSessionResponse?>, t: Throwable) {
                throw RuntimeException(t.message)
            }
        })
    }

    fun startArchive() {
        if (session != null) {
            val startArchiveRequest = StartArchiveRequest()
            startArchiveRequest.sessionId = sessionId

            val call = apiService.startArchive(startArchiveRequest)
            call.enqueue(EmptyCallback())
        }
    }

    fun stopArchive() {
        val call = apiService.stopArchive(currentArchiveId)
        call.enqueue(EmptyCallback())
    }

    fun playArchive() {
        val archiveUrl = "${ServerConfig.CHAT_SERVER_URL}/archive/${playableArchiveId}/view"
        val archiveUri = Uri.parse(archiveUrl)
        val browserIntent = Intent(Intent.ACTION_VIEW, archiveUri)
        activity?.startActivity(browserIntent)
    }
}