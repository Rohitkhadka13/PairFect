import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pairfect/chats/message_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ParseObject> chatRooms = [];
  late ParseUser currentUser;
  bool isLoading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    initChats();
    refreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => fetchChats());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> initChats() async {
    final user = await ParseUser.currentUser();
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    currentUser = user;
    await fetchChats();
  }

  Future<void> fetchChats() async {
    if (!mounted) return;

    final senderQuery = QueryBuilder<ParseObject>(ParseObject('ChatRoom'))
      ..whereEqualTo('sender', currentUser);
    final receiverQuery = QueryBuilder<ParseObject>(ParseObject('ChatRoom'))
      ..whereEqualTo('receiver', currentUser);

    final query =
        QueryBuilder.or(ParseObject('ChatRoom'), [senderQuery, receiverQuery])
          ..orderByDescending('updatedAt')
          ..includeObject(['sender', 'receiver']);

    final response = await query.query();

    if (!mounted) return;

    if (response.success && response.results != null) {
      setState(() {
        chatRooms = (response.results as List<ParseObject>).where((chatRoom) {
          final sender = chatRoom.get<ParseUser>('sender');
          final receiver = chatRoom.get<ParseUser>('receiver');
          return sender != null && receiver != null;
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        chatRooms = [];
        isLoading = false;
      });
    }
  }

  ParseUser? getReceiver(ParseObject chatRoom) {
    final sender = chatRoom.get<ParseUser>('sender');
    final receiver = chatRoom.get<ParseUser>('receiver');
    if (sender == null || receiver == null) return null;
    return sender.objectId == currentUser.objectId ? receiver : sender;
  }

  Future<ParseObject?> fetchUserLogin(ParseUser user) async {
    if (user.objectId == null) return null;

    final userPointer = ParseObject('_User')..objectId = user.objectId;

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', userPointer);

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        (response.results as List).isNotEmpty) {
      return (response.results as List).first as ParseObject;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: fetchChats,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : chatRooms.isEmpty
                ? const Center(child: Text("No chats yet"))
                : ListView.separated(
                    itemCount: chatRooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      final receiver = getReceiver(chatRoom);
                      if (receiver == null) return const SizedBox();
                      return ChatListTile(
                        receiver: receiver,
                        chatRoom: chatRoom,
                        fetchUserLogin: fetchUserLogin,
                        onTap: (receiverName) {
                          Get.to(() => ChatScreen(), arguments: {
                            'chatRoomId': chatRoom.objectId,
                            'receiverName': receiverName,
                          });
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class ChatListTile extends StatefulWidget {
  final ParseUser receiver;
  final ParseObject chatRoom;
  final Future<ParseObject?> Function(ParseUser) fetchUserLogin;
  final void Function(String receiverName) onTap;

  const ChatListTile({
    Key? key,
    required this.receiver,
    required this.chatRoom,
    required this.fetchUserLogin,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  ParseObject? _cachedUserLogin;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadUserLogin();
  }

  Future<void> _loadUserLogin() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final data = await widget.fetchUserLogin(widget.receiver);
      if (data != null) {
        setState(() {
          _cachedUserLogin = data;
        });
      }
    } catch (_) {
      setState(() {
        _error = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void didUpdateWidget(covariant ChatListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receiver.objectId != widget.receiver.objectId) {
      _loadUserLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLogin = _cachedUserLogin;
    final receiverName =
        userLogin?.get<String>('name') ?? widget.receiver.username ?? 'Unknown';
    final ParseFile? imageFile = userLogin?.get<ParseFile>('imageProfile');
    final imageUrl = imageFile?.url ?? 'https://i.pravatar.cc/150';
    final lastMessage = widget.chatRoom.get<String>('lastMessage') ?? '';
    final updatedAt = widget.chatRoom.updatedAt != null
        ? "${widget.chatRoom.updatedAt!.toLocal()}".substring(0, 16)
        : '';

    if (_loading && userLogin == null) {
      return ListTile(
        title: Text(widget.receiver.username ?? 'Loading...'),
        leading: const CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
        ),
      );
    }

    if (_error && userLogin == null) {
      return ListTile(
        title: Text(widget.receiver.username ?? 'Error'),
        leading: const CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(receiverName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(updatedAt, style: const TextStyle(color: Colors.grey)),
      onTap: () => widget.onTap(receiverName),
    );
  }
}
