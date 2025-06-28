import 'package:flutter/material.dart';
import 'package:sanjeevika/utils/functions_uses.dart';
import '../../../services/ai_service.dart';

double size = SizeConfig.screenWidth;

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! Welcome to Sanjeevika App. I'm your AI health assistant.\nHow can I help you today?",
      isBot: true,
      time: "11:51 PM",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkApiConfiguration();
  }

  void _checkApiConfiguration() {
    if (!SanjeevikaAIService.isApiKeyConfigured()) {}
  }

  Future<void> _sendMessage() async {
    final input = _messageController.text.trim();
    if (input.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: input,
        isBot: false,
        time: _getCurrentTime(),
      ));
      _isLoading = true;
    });

    _messageController.clear();

    // Get AI response
    try {
      final response = await SanjeevikaAIService.generateResponse(input);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isBot: true,
          time: _getCurrentTime(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text:
              "I apologize, but I'm experiencing some technical difficulties. Please try again in a moment. If the problem persists, please contact our support team.",
          isBot: true,
          time: _getCurrentTime(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return "${hour == 0 ? 12 : hour}:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFFE2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: -5,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_outline_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sanjeevika AI Chat Assistant',
                  style: TextStyle(
                    color: Color(0xFF003313),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isLoading ? '• Typing...' : '• Online',
                  style: TextStyle(
                    color: _isLoading ? Colors.orange : const Color(0xFF4FB700),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background logo when only welcome message is present
          if (_messages.length <= 1)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sanjeevikalogo.png',
                      width: size / 3,
                    ),
                  ],
                )
              ],
            ),
          Column(
            children: [
              // Chat messages list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const LoadingBubble();
                    }
                    final message = _messages[index];
                    return ChatBubble(message: message);
                  },
                ),
              ),

              // Message input area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: Colors.grey, width: 0.2)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      _buildIconButton(
                        Icons.photo_library_outlined,
                        backgroundColor: const Color(0xFFBBF7D0),
                        borderColor: const Color(0xFF02A820),
                        iconColor: const Color(0xFF02A820),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: const Color(0xFFBBF7D0), width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Ask me about your health, medications...',
                                    hintStyle:
                                        TextStyle(color: Color(0xFF919191)),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                  enabled: !_isLoading,
                                ),
                              ),
                              _buildIconButton(
                                Icons.mic_none,
                                size: 30,
                                borderColor: const Color(0xFFBBF7D0),
                                backgroundColor: Colors.white,
                                iconColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        _isLoading
                            ? Icons.hourglass_empty
                            : Icons.send_outlined,
                        backgroundColor: _isLoading
                            ? Colors.grey.shade300
                            : const Color(0xFFBBF7D0),
                        borderColor:
                            _isLoading ? Colors.grey : const Color(0xFF02A820),
                        iconColor:
                            _isLoading ? Colors.grey : const Color(0xFF02A820),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color backgroundColor = const Color(0xFFE8F5E8),
    Color borderColor = Colors.transparent,
    Color iconColor = Colors.grey,
    double size = 25,
    void Function()? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final String time;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.time,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.isBot)
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_outlined,
                      color: Colors.white, size: 15),
                ),
                const SizedBox(width: 4),
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6F6F6F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment:
                message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: message.isBot
                            ? Colors.white
                            : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isBot ? Colors.black87 : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.chat_bubble_outline_outlined,
                    color: Colors.white, size: 15),
              ),
              const SizedBox(width: 4),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6F6F6F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI is typing...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
