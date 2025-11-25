import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ChatController extends GetxController {
  final RxList<ParseObject> messages = <ParseObject>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late String chatRoomId;
  final RxString receiverName = ''.obs;
  late ParseUser currentUser;
  Timer? _messagePollingTimer;
  final RxBool _isLoadingMessages = false.obs;

  final RxBool aiEnabled = false.obs;
  final RxBool isGeneratingAIResponse = false.obs;
  final RxList<String> aiSuggestions = <String>[].obs;
  final RxString aiError = ''.obs;
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final String _apiKey = "AIzaSyAklAyTap5LNbPjV6wNAaORM5_ON6x9uLg";
  final int _messagesPerPage = 20;
  final RxBool _hasMoreMessages = true.obs;

  ChatController({required this.chatRoomId, required String receiverName}) {
    this.receiverName.value = receiverName;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    _startMessagePolling();
  }

  @override
  void onClose() {
    _messagePollingTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initializeChat() async {
    try {
      currentUser = await ParseUser.currentUser() as ParseUser;
      await _loadMessages();
    } catch (e) {
      _showError('Failed to initialize chat: ${e.toString()}');
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (_isLoadingMessages.value || (!loadMore && !_hasMoreMessages.value)) return;

    _isLoadingMessages.value = true;

    try {
      final chatRoomPointer = ParseObject('ChatRoom')..objectId = chatRoomId;
      final query = QueryBuilder<ParseObject>(ParseObject('Message'))
        ..whereEqualTo('chatRoomId', chatRoomPointer)
        ..orderByDescending('createdAt');

      if (loadMore && messages.isNotEmpty) {
        query.whereGreaterThan('createdAt', messages.last.createdAt);
      }

      final result = await query.find();

      if (loadMore) {
        messages.addAll(result.reversed);
      } else {
        messages.assignAll(result.reversed);
      }

      _hasMoreMessages.value = result.length == _messagesPerPage;

      if (messages.isNotEmpty) {
        await _updateLastMessage(messages.last.get<String>('content') ?? '');

        if (_shouldGenerateReply(messages.last)) {
          await _generateAISuggestions(messages.last.get<String>('content') ?? '');
        }
      }

      _scrollToBottom();
    } catch (e) {
      _showError('Failed to load messages: ${e.toString()}');
    } finally {
      _isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final chatRoomPointer = ParseObject('ChatRoom')..objectId = chatRoomId;
      final message = ParseObject('Message')
        ..set('chatRoomId', chatRoomPointer)
        ..set('sender', currentUser)
        ..set('content', content.trim());

      final saved = await message.save();
      if (saved.success && saved.result != null) {
        final savedMessage = saved.result as ParseObject;
        messages.add(savedMessage);
        textController.clear();
        _scrollToBottom();
      }

      await _updateLastMessage(content);
      aiSuggestions.clear();
    } catch (e) {
      _showError('Failed to send message: ${e.toString()}');
    }
  }

  bool isCurrentUser(ParseObject message) {
    final sender = message.get<ParseUser>('sender');
    return sender?.objectId == currentUser.objectId;
  }

  void generateAIResponse(String message) {
    _generateAISuggestions(message);
  }

  Future<void> _generateAISuggestions(String message) async {
    if (!aiEnabled.value || isGeneratingAIResponse.value) return;

    isGeneratingAIResponse.value = true;
    aiError.value = '';
    aiSuggestions.clear();

    try {
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                  "Suggest 3 short (1-5 word) reply  options for: '$message'. "
                      "Format as: 1) Suggestion1 2) Suggestion2 3) Suggestion3"
                }
              ]
            }
          ],
          "generationConfig": {
            "maxOutputTokens": 100,
            "temperature": 0.7
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          final suggestions = RegExp(r'\d\)\s*(.+?)(?=\s*\d\)|$)')
              .allMatches(text)
              .map((m) => m.group(1)?.trim() ?? '')
              .where((s) => s.isNotEmpty)
              .take(3)
              .toList();

          if (suggestions.isNotEmpty) {
            aiSuggestions.assignAll(suggestions);
          } else {
            aiError.value = 'No valid suggestions found';
          }
        }
      } else {
        aiError.value = 'API Error: ${response.statusCode}';
      }
    } catch (e) {
      aiError.value = 'Connection failed: ${e.toString()}';
    } finally {
      isGeneratingAIResponse.value = false;
      if (aiError.isNotEmpty) {
        _showError(aiError.value);
      }
    }
  }

  void useAISuggestion(String suggestion) {
    textController.text = suggestion;
    aiSuggestions.clear();
  }

  bool _shouldGenerateReply(ParseObject message) {
    return !isCurrentUser(message) &&
        aiEnabled.value &&
        textController.text.isEmpty &&
        aiSuggestions.isEmpty;
  }

  Future<void> _updateLastMessage(String content) async {
    try {
      final chatRoom = ParseObject('ChatRoom')..objectId = chatRoomId;
      chatRoom.set('lastMessage', content);
      await chatRoom.save();
    } catch (e) {
      debugPrint('Failed to update last message: ${e.toString()}');
    }
  }

  void _startMessagePolling() {
    _messagePollingTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _loadMessages(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> loadMoreMessages() => _loadMessages(loadMore: true);
  bool get hasMoreMessages => _hasMoreMessages.value;
  bool get isLoadingMessages => _isLoadingMessages.value;
}
