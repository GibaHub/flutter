import 'package:flutter/material.dart';
import '../../data/chat_service.dart';
import '../../data/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String appointmentId;

  const ChatScreen({super.key, required this.appointmentId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [];
  String? _currentUserId; // In real app, get from Token
  bool _isSessionActive = true; // Check this via API in init

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final token = await _authService.getToken();
    if (token != null) {
      _currentUserId = "user_id_from_token"; // Decode token in real app
      _chatService.connect(token);
      _chatService.joinRoom(widget.appointmentId);
      
      _chatService.onNewMessage((data) {
        if (mounted) {
          setState(() {
            _messages.add(data);
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    
    // Mock senderId for now since we don't have real auth decoding yet
    // In production, decoding JWT or getting profile is needed
    final senderId = _currentUserId ?? "temp_user"; 

    _chatService.sendMessage(
      widget.appointmentId,
      senderId,
      _textController.text,
    );
    _textController.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload logic here (POST to /upload endpoint)
      // Then send message with fileUrl
      print("Image picked: ${image.path}");
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimento Online'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          if (!_isSessionActive)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.2),
              width: double.infinity,
              child: const Text(
                'Sessão encerrada. Chat somente leitura.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['senderId'] == _currentUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg['type'] == 'IMAGE')
                           const Icon(Icons.image, size: 50) // Placeholder
                        else
                           Text(msg['content'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          '14:00', // Mock time
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSessionActive)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _pickImage, // Attachment
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
