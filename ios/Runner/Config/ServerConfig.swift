import Foundation

class ServerConfig {
    /*
    You can set up a server to provide session information. To quickly set up a pre-made web service, see
    https://github.com/opentok/learning-opentok-php
    or
    https://github.com/opentok/learning-opentok-node
    After deploying the server open the `ServerConfig` file in this project and configure the `CHAT_SERVER_URL`
    with your domain to fetch credentials from the server.

    Setting this is REQUIRED for the Archiving example, however other examples allow you to hardcode
    the session information in the Flutter config code
    */
    var CHAT_SERVER_URL = ""
}
