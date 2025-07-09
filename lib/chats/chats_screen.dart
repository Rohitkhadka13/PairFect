import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetchChats());
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

    final query = QueryBuilder.or(ParseObject('ChatRoom'), [senderQuery, receiverQuery])
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
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text(
          'My Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF881337),
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF881337)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF2F8),
              Color(0xFFFBCFE8),
            ],
          ),
        ),
        child: RefreshIndicator(
          backgroundColor: const Color(0xFFFBCFE8),
          color: const Color(0xFF881337),
          onRefresh: fetchChats,
          child: isLoading
              ? _buildLoadingState()
              : chatRooms.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            itemCount: chatRooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final receiver = getReceiver(chatRoom);
              if (receiver == null) return const SizedBox();
              return ChatListTile(
                receiver: receiver,
                chatRoom: chatRoom,
                fetchUserLogin: fetchUserLogin,
                onTap: (receiverName) {
                  Get.to(
                        () => ChatScreen(),
                    arguments: {
                      'chatRoomId': chatRoom.objectId,
                      'receiverName': receiverName,
                    },
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF881337),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading your conversations",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.pink.shade200,
          ),
          const SizedBox(height: 20),
          const Text(
            "No conversations yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF881337),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Start a new romantic connection by messaging someone special",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add your navigation to find matches here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB7185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Find Matches",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
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
    final imageUrl = imageFile?.url ?? 'https://i.pravatar.cc/150?img=3';
    final lastMessage = widget.chatRoom.get<String>('lastMessage') ?? '';
    final updatedAt = widget.chatRoom.updatedAt != null
        ? _formatDateTime(widget.chatRoom.updatedAt!)
        : '';

    if (_loading && userLogin == null) {
      return _buildSkeletonLoader();
    }

    if (_error && userLogin == null) {
      return _buildErrorTile();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => widget.onTap(receiverName),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade100,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF9A8D4),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF881337),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage.isNotEmpty
                          ? lastMessage
                          : 'Start your conversation...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: lastMessage.isNotEmpty
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                        fontStyle: lastMessage.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    updatedAt,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.chatRoom.get<int>('unreadCount') != null &&
                      widget.chatRoom.get<int>('unreadCount')! > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFB7185),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        widget.chatRoom.get<int>('unreadCount').toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFBCFE8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBCFE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBCFE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: _loadUserLogin,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFF881337),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Error loading chat',
                  style: TextStyle(
                    color: Color(0xFF881337),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.refresh,
                color: Color(0xFF881337),
              ),
            ],
          ),
        ),
      ),
    );
  }
}