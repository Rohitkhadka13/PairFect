import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ChatController extends GetxController {
  final messages = <ParseObject>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late String chatRoomId;
  RxString receiverName = ''.obs;
  late ParseUser currentUser;
  Timer? messageTimer;

  ChatController({required this.chatRoomId, required String receiverName}) {
    this.receiverName.value = receiverName;
  }

  @override
  void onInit() {
    super.onInit();
    initChat();
    messageTimer = Timer.periodic(Duration(seconds: 5), (_) => loadMessages());
  }

  @override
  void onClose() {
    messageTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> initChat() async {
    currentUser = await ParseUser.currentUser() as ParseUser;
    await loadMessages();
  }

  Future<void> loadMessages() async {
    final chatRoomPointer = ParseObject('ChatRoom')..objectId = chatRoomId;

    final query = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('chatRoomId', chatRoomPointer)
      ..orderByAscending('createdAt');

    final result = await query.find();
    messages.assignAll(result);
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      final content = lastMsg.get<String>('content') ?? '';

      final chatRoom = ParseObject('ChatRoom')..objectId = chatRoomId;
      chatRoom.set('lastMessage', content);
      await chatRoom.save();
    }

    // Scroll to bottom after loading
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final chatRoomPointer = ParseObject('ChatRoom')..objectId = chatRoomId;

    final message = ParseObject('Message')
      ..set('chatRoomId', chatRoomPointer)
      ..set('sender', currentUser)
      ..set('content', content);

    await message.save();

    // Update lastMessage immediately after sending
    final chatRoom = ParseObject('ChatRoom')..objectId = chatRoomId;
    chatRoom.set('lastMessage', content);
    await chatRoom.save();

    textController.clear();
    await loadMessages();
  }

  bool isCurrentUser(ParseObject msg) {
    final sender = msg.get<ParseUser>('sender');
    return sender?.objectId == currentUser.objectId;
  }
}
