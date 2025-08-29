enum MessageType { user, assistant, tool }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isStreaming;
  final bool hasError;
  final String? toolCallId;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isStreaming = false,
    this.hasError = false,
    this.toolCallId,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isStreaming,
    bool? hasError,
    String? toolCallId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      toolCallId: toolCallId ?? this.toolCallId,
    );
  }

  Map<String, String> toApiFormat() {
    final map = {
      'role': type.name,
      'content': content,
    };
    if (toolCallId != null) {
      map['tool_call_id'] = toolCallId!;
    }
    return map;
  }

  factory Message.user(String content) {
    return Message(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory Message.assistant(String content, {bool isStreaming = false}) {
    return Message(
      id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
    );
  }

  factory Message.error(String content) {
    return Message(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      hasError: true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
