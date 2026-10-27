package ke.co.vexaryn.netscope

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val channelName = "ke.co.vexaryn.netscope/network"
    private val executor = Executors.newFixedThreadPool(12)
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "isHostReachable" -> {
                    val ip = call.argument<String>("ip")
                    val timeout = (
                            call.argument<Int>("timeout") ?: 700
                            ).coerceIn(100, 2000)

                    if (ip == null ||
                        !Regex("""\d{1,3}(\.\d{1,3}){3}""").matches(ip) ||
                        ip.split(".").any {
                            (it.toIntOrNull() ?: -1) !in 0..255
                        }
                    ) {
                        result.error(
                            "INVALID_IP",
                            "Valid IPv4 address required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    executor.execute {
                        val reachable = try {
                            InetAddress.getByName(ip)
                                .isReachable(timeout)
                        } catch (e: Exception) {
                            false
                        }

                        mainHandler.post {
                            result.success(reachable)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }
}
