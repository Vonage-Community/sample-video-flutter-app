package com.vonage.tutorial.opentok.opentok_flutter_samples.archiving.networking

import com.squareup.moshi.Json

class StartArchiveRequest {
    @Json(name = "sessionId")
    var sessionId: String? = null
}