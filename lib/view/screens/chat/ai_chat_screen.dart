import 'package:flutter/material.dart';
import 'package:sanjeevika/utils/functions_uses.dart';
import '../../../services/ai_service.dart';

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
      time: "",
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

    setState(() {
      _messages.add(ChatMessage(
        text: input,
        isBot: false,
        time: _getCurrentTime(),
      ));
      _isLoading = true;
    });

    _messageController.clear();

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
    final size = MediaQuery.of(context).size;

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
              width: size.width * 0.08,
              height: size.width * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(size.width * 0.04),
              ),
              child: const Icon(Icons.chat_bubble_outline_outlined,
                  color: Colors.white, size: 18),
            ),
            SizedBox(width: size.width * 0.025),
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
          if (_messages.length <= 1)
            Center(
              child: Image.asset(
                'assets/images/sanjeevikalogo.png',
                width: size.width * 0.33,
              ),
            ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(size.width * 0.04),
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
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.2),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(size.width * 0.06),
                            border: Border.all(
                                color: const Color(0xFFBBF7D0), width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ask me anything.....',
                                    hintStyle:
                                        TextStyle(color: Color(0xFF919191)),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                  enabled: !_isLoading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Colors.black),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size * 0.6),
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
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.006),
      child: Column(
        crossAxisAlignment:
            message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.isBot)
            Row(
              children: [
                Container(
                  width: size.width * 0.08,
                  height: size.width * 0.08,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_outlined,
                      color: Colors.white, size: 15),
                ),
                SizedBox(width: size.width * 0.01),
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
          SizedBox(height: size.height * 0.005),
          Row(
            mainAxisAlignment:
                message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.width * 0.035),
                      decoration: BoxDecoration(
                        color: message.isBot
                            ? Colors.white
                            : const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(size.width * 0.05),
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
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: size.width * 0.025,
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
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.006),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.08,
                height: size.width * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(size.width * 0.04),
                ),
                child: const Icon(Icons.chat_bubble_outline_outlined,
                    color: Colors.white, size: 15),
              ),
              SizedBox(width: size.width * 0.01),
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
          SizedBox(height: size.height * 0.005),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.width * 0.035),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size.width * 0.05),
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
                        width: size.width * 0.04,
                        height: size.width * 0.04,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
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
