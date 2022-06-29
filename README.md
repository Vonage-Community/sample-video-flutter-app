# OpenTok Flutter Sample

This project provides a sample Flutter project that highlights how to make use of the Android and iOS OpenTok SDK features within a cross platform flutter application.

## Setup flutter SDK
The flutter site has a solid [install guide](https://docs.flutter.dev/get-started/install) follow this to make sure that flutter is setup correctly. 

Note that if you plan to build for iOS you will need to do this on a Mac, for Android all platforms are supported.

## Set up credentials
To get started you will need a valid [Vonage Video API account](https://tokbox.com/account/user/signup). You will find your API credentials (API_KEY, SESSION_ID, TOKEN) which you can find in the Video API Dashboard.

Add these credentials to [lib/src/config/open_tok_config.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/src/config/open_tok_config.dart).

## Run the App
The quickest way to run/test the project is to open the project using [Android Studio](https://developer.android.com/studio) using the [Flutter plugin](https://flutter.dev/docs/development/tools/android-studio). Once opened you can run the project targeting your platform of choice. For more details on other options please see the [flutter test drive guide](https://docs.flutter.dev/get-started/test-drive)

## App Features
The app is broken down into separate classes for separate SDK features, this architecture would not be used in a production application however it allows for clean code readability on what you will need to implement for each specific feature.

### One to One video
This is a basic one to one video chat implementation, the flutter code can be found in [lib/one_to_one_video.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/one_to_one_video.dart).

The supporting Android native code can be found in the directory [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/one_to_one_video](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/one_to_one_video).

The supporting iOS native code can be found in the directory [ios/Runner/OneToOneVideo](https://github.com/opentok/opentok-flutter-samples/blob/main/ios/Runner/OneToOneVideo).

For Android a native FrameLayout is used to hold the video render view for both streams (the subscriber and the publisher). The flutter layout highlights how to make use of these native views.

### Multi Party Video
This is an example of how you can implement multi party video chat, the flutter code can be found in [lib/multi_video.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/multi_video.dart).

The supporting Android native code can be found in the directory [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/multi_video](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/multi_video).

The supporting iOS native code can be found in the directory [ios/Runner/MultiVideo](https://github.com/opentok/opentok-flutter-samples/blob/main/ios/Runner/MultiVideo).

For Android a native ConstraintLayout to which views are added/removed as users join/leave the session.

### Signalling (Text Messaging)
This shows how to implement a basic "messaging" client between those within a opentok session. This allows you to send text messages back and forth and often is a feature that's used alongside the video chat functionality.

The flutter code can be found in [lib/signalling.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/signalling.dart). This makes use of a all UI elements being rendered by Flutter and only data being sent/received by the SDK and native code.

The supporting Android native code cen be found in the directory [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/signalling](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/signalling)

The supporting iOS native code can be found in the directory [ios/Runner/Archiving](https://github.com/opentok/opentok-flutter-samples/blob/main/ios/Runner/Archiving).

### Screen/View Sharing
This shows how you can set and use a custom video capturer based on a webview as the source fo a published video stream instead of taking the camera feed.

The flutter code can be found in [lib/screen_sharing.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/screen_sharing.dart). 

The supporting Android native code cen be found in the directory [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/screen_sharing](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/screen_sharing)

### Archiving
This shows how to interact with a webservice and the OpenTok cloud to enable the recording (Archiving) of video chat sessions as well as replaying them.

The flutter code can be found in [lib/archiving.dart](https://github.com/opentok/opentok-flutter-samples/blob/main/lib/archiving.dart). 

The supporting Android native code cen be found in the directory [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/archiving](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/archiving)

The supporting iOS native code can be found in the directory [ios/Runner/Archiving](https://github.com/opentok/opentok-flutter-samples/blob/main/ios/Runner/Archiving).

Recording archives are stored on OpenTok cloud (not on the user device), so we'll need to set up a web service that communicates with OpenTok cloud to start and stop archiving.

In order to archive OpenTok sessions, you need to have a server set up (hardcoded session information will not work for archiving). To quickly deploy a pre-built server click at one of the Heroku buttons below. You'll be sent to Heroku's website and prompted for your OpenTok `API Key` and `API Secret` — you can obtain these values on your project page in your [TokBox account](https://tokbox.com/account/user/signup). If you don't have a Heroku account, you'll need to sign up (it's free).

| PHP server  | Node.js server|
| ------------- | ------------- |
| <a href="https://heroku.com/deploy?template=https://github.com/opentok/learning-opentok-php" target="_blank"> <img src="https://www.herokucdn.com/deploy/button.png" alt="Deploy"></a>  | <a href="https://heroku.com/deploy?template=https://github.com/opentok/learning-opentok-node" target="_blank"> <img src="https://www.herokucdn.com/deploy/button.png" alt="Deploy"></a>  |
| [Repository](https://github.com/opentok/learning-opentok-php) | [Repository](https://github.com/opentok/learning-opentok-node) |

This sample web service provides a RESTful interface to interact with archiving controls.

> Note: You can also build your server from scratch using one of the [server SDKs](https://tokbox.com/developer/sdks/server/).

After deploying the server open [android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/config/ServerConfig.kt](https://github.com/opentok/opentok-flutter-samples/blob/main/android/app/src/main/kotlin/com/vonage/tutorial/opentok/opentok_flutter_samples/config/ServerConfig.kt) and configure the `CHAT_SERVER_URL` with your domain to fetch credentials from the server.
