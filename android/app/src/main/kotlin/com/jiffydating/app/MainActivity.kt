package com.jiffydating.app

import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.jiffydating.app/install_referrer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstallReferrer") {
                val referrerClient = InstallReferrerClient.newBuilder(this).build()
                try {
                    referrerClient.startConnection(object : InstallReferrerStateListener {
                        override fun onInstallReferrerSetupFinished(responseCode: Int) {
                            when (responseCode) {
                                InstallReferrerClient.InstallReferrerResponse.OK -> {
                                    try {
                                        val response: ReferrerDetails = referrerClient.installReferrer
                                        result.success(response.installReferrer)
                                    } catch (e: Exception) {
                                        result.error("REFERRER_READ_ERROR", e.message, null)
                                    } finally {
                                        try {
                                            referrerClient.endConnection()
                                        } catch (_: Exception) {}
                                    }
                                }
                                InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED -> {
                                    try { referrerClient.endConnection() } catch (_: Exception) {}
                                    result.error("FEATURE_NOT_SUPPORTED", "Play Store not supported or outdated", null)
                                }
                                InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                                    try { referrerClient.endConnection() } catch (_: Exception) {}
                                    result.error("SERVICE_UNAVAILABLE", "Cannot connect to Play Store service", null)
                                }
                                else -> {
                                    try { referrerClient.endConnection() } catch (_: Exception) {}
                                    result.error("RESPONSE_CODE_$responseCode", "Referrer returned responseCode: $responseCode", null)
                                }
                            }
                        }

                        override fun onInstallReferrerServiceDisconnected() {
                            // Service disconnected; will retry or ignore safely
                        }
                    })
                } catch (e: Exception) {
                    result.error("EXCEPTION", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

