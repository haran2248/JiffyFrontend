import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class VoiceService {
  String get apiKey => dotenv.env['DEEPGRAM_API_KEY'] ?? '';

  final AudioRecorder _audioRecorder = AudioRecorder();
  IOWebSocketChannel? _channel;
  StreamSubscription? _audioSubscription;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint("Microphone permission denied");
        return false;
      }
    }
    return true;
  }

  Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    required VoidCallback onDone,
  }) async {
    if (_isListening) return false;

    final initSuccess = await initialize();
    if (!initSuccess) return false;

    _isListening = true;

    try {
      // Connect to Deepgram WebSocket. Nova-2 is the most powerful model, optimized for general speech.
      // We set interim_results=true to get real-time streaming text as the user speaks.
      final uri = Uri.parse(
          'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=16000&language=en-IN&model=nova-2&interim_results=true&endpointing=false&no_delay=true');
      
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Authorization': 'Token $apiKey',
        },
      );
      
      // Listen to Deepgram responses
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'Results') {
              final isFinal = data['is_final'] == true;
              final transcript = data['channel']['alternatives'][0]['transcript'] as String;
              
              if (transcript.isNotEmpty || isFinal) {
                onResult(transcript, isFinal);
              }
            }
          } catch (e) {
            debugPrint("Error parsing Deepgram message: $e");
          }
        },
        onDone: () {
          debugPrint('Deepgram WebSocket Closed');
          _cleanup();
          onDone();
        },
        onError: (error) {
          debugPrint('Deepgram WebSocket Error: $error');
          _cleanup();
          onDone();
        },
      );

      // Start capturing raw audio stream (16kHz PCM is standard for Deepgram)
      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Pipe the raw audio directly into the WebSocket
      _audioSubscription = audioStream.listen((data) {
        if (_channel != null && _isListening) {
          _channel!.sink.add(data);
        }
      });

      return true;
    } catch (e) {
      debugPrint("VoiceService start error: $e");
      _cleanup();
      onDone();
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    // Tell Deepgram we are done sending audio
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({"type": "CloseStream"}));
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    _cleanup();
  }

  Future<void> cancelListening() async {
    _cleanup();
  }

  void _cleanup() {
    _isListening = false;
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioRecorder.stop();
    _channel?.sink.close();
    _channel = null;
  }
}
