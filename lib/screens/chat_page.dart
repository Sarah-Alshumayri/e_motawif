import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class ChatPage extends StatefulWidget {
  final String motawifId;
  final String pilgrimId;
  final String pilgrimName;
  final String userRole; // ✅ added

  const ChatPage({
    Key? key,
    required this.motawifId,
    required this.pilgrimId,
    required this.pilgrimName,
    required this.userRole, // ✅ added
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Color primaryColor = const Color(0xFF0D4A45);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final isMotawif = widget.userRole.toLowerCase() == 'motawif';
      final senderId = isMotawif ? widget.motawifId : widget.pilgrimId;
      final receiverId = isMotawif ? widget.pilgrimId : widget.motawifId;

      final url = Uri.parse('http://10.0.2.2/e_motawif_new/get_messages.php');
      final response = await http.post(url, body: {
        'sender_id': senderId,
        'receiver_id': receiverId,
      });

      print("🔁 Fetching messages: $senderId -> $receiverId");
      print("📦 Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _messages = List<Map<String, dynamic>>.from(
              data['messages'].map((msg) => {
                    'text': msg['message'],
                    'isMe': msg['sender_id'] == senderId,
                    'timestamp': DateTime.parse(msg['timestamp']),
                    'sender': msg['sender_id'] == senderId
                        ? (isMotawif ? 'Motawif' : 'You')
                        : (isMotawif ? 'Pilgrim' : 'Motawif'),
                  }),
            );
          });

          // Scroll to the latest message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final isMotawif = widget.userRole.toLowerCase() == 'motawif';
    final senderId = isMotawif ? widget.motawifId : widget.pilgrimId;
    final receiverId = isMotawif ? widget.pilgrimId : widget.motawifId;

    final text = _controller.text.trim();
    _controller.clear();

    print("📤 Sending message: $text");
    print("📦 Sender ID: $senderId, Receiver ID: $receiverId");

    setState(() {
      _messages.add({
        "text": text,
        "isMe": true,
        "timestamp": DateTime.now(),
        "sender": "You"
      });
    });

    // 🔹 Send the message to backend
    final messageUrl =
        Uri.parse('http://10.0.2.2/e_motawif_new/send_message.php');
    final response = await http.post(messageUrl, body: {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': text,
    });

    print("📨 Response from send_message.php: ${response.body}");

    // 🔔 Send backend notification
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? senderName = prefs.getString('name');

    final notificationUrl =
        Uri.parse('http://10.0.2.2/e_motawif_new/send_notification.php');
    final notificationResponse = await http.post(notificationUrl, body: {
      'user_id': receiverId,
      'title': 'New Message',
      'message': 'You received a new message from $senderName.',
      'sender_name': senderName ?? 'Someone'
    });

    print("🔔 Notification response: ${notificationResponse.body}");

    // 🔔 Local notification
    await NotificationService.showNotification(
      title: 'New Message',
      body: 'You sent a message to ${widget.pilgrimName}',
    );

    // Refresh messages
    _fetchMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _formatTimestamp(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pilgrimName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe
                          ? primaryColor.withOpacity(0.9)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${message['sender']} • ${_formatTimestamp(message['timestamp'])}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0D4A45)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
