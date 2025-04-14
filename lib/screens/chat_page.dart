import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String motawifId;
  final String pilgrimId;
  final String pilgrimName;

  const ChatPage({
    Key? key,
    required this.motawifId,
    required this.pilgrimId,
    required this.pilgrimName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Color primaryColor = const Color(0xFF0D4A45);
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> _messages = [
    {
      "text": "Salam, how are you today?",
      "isMe": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "sender": "Pilgrim"
    },
    {
      "text": "Doing well, thank you! How are you feeling?",
      "isMe": true,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "sender": "Motawif"
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": _controller.text.trim(),
        "isMe": true,
        "timestamp": DateTime.now(),
        "sender": "Motawif"
      });
      _controller.clear();
    });

    // ⏳ Future integration: Send message to backend here
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
