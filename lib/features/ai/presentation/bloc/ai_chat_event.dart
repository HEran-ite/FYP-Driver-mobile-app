library;

import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => const [];
}

class AiSessionsRequested extends AiChatEvent {
  const AiSessionsRequested();
}

class AiSessionSelected extends AiChatEvent {
  const AiSessionSelected(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class AiStartSessionRequested extends AiChatEvent {
  const AiStartSessionRequested({
    this.vehicleId,
    this.title,
  });

  final String? vehicleId;
  final String? title;

  @override
  List<Object?> get props => [vehicleId, title];
}

class AiMessagesRequested extends AiChatEvent {
  const AiMessagesRequested({
    required this.sessionId,
    this.refresh = true,
  });

  final String sessionId;
  final bool refresh;

  @override
  List<Object?> get props => [sessionId, refresh];
}

class AiOlderMessagesRequested extends AiChatEvent {
  const AiOlderMessagesRequested();
}

class AiSessionDeleteRequested extends AiChatEvent {
  const AiSessionDeleteRequested(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class AiMessageSendRequested extends AiChatEvent {
  const AiMessageSendRequested(
    this.message, {
    this.vehicleId,
    this.sessionTitle,
  });

  final String message;
  final String? vehicleId;
  final String? sessionTitle;

  @override
  List<Object?> get props => [message, vehicleId, sessionTitle];
}
