library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../data/models/ai_message_model.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_event.dart';
import '../bloc/ai_chat_state.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicles_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicles_event.dart';
import '../../../vehicles/presentation/bloc/vehicles_state.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({
    super.key,
    this.initialSessionId,
    this.initialVehicleId,
  });

  final String? initialSessionId;
  final String? initialVehicleId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = getIt<AiChatBloc>()..add(const AiSessionsRequested());
            final sid = initialSessionId?.trim();
            if (sid != null && sid.isNotEmpty) {
              bloc.add(AiSessionSelected(sid));
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) =>
              getIt<VehiclesBloc>()..add(const VehiclesLoadRequested()),
        ),
      ],
      child: _AiChatView(initialVehicleId: initialVehicleId),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView({this.initialVehicleId});

  final String? initialVehicleId;

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedVehicleId;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openHistory() async {
    final result = await Navigator.of(context).pushNamed('/ai-chat/history');
    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      if (result == '__new__') {
        _startNewChat();
      } else {
        context.read<AiChatBloc>().add(AiSessionSelected(result));
      }
    }
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    final selectedVehicle = _currentSelectedVehicle(context);
    final sessionTitle = _buildUniqueSessionTitle(selectedVehicle);
    context.read<AiChatBloc>().add(
      AiMessageSendRequested(
        text,
        vehicleId: selectedVehicle?.id,
        sessionTitle: sessionTitle,
      ),
    );
    _scrollToBottom();
  }

  void _startNewChat() {
    final selectedVehicle = _currentSelectedVehicle(context);
    final sessionTitle = _buildUniqueSessionTitle(selectedVehicle);
    context.read<AiChatBloc>().add(
      AiStartSessionRequested(
        vehicleId: selectedVehicle?.id,
        title: sessionTitle,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Vehicle? _currentSelectedVehicle(BuildContext context) {
    final vState = context.read<VehiclesBloc>().state;
    if (vState is! VehiclesLoaded || vState.vehicles.isEmpty) return null;
    if (_selectedVehicleId != null) {
      for (final v in vState.vehicles) {
        if (v.id == _selectedVehicleId) return v;
      }
    }
    return vState.vehicles.first;
  }

  String _buildUniqueSessionTitle(Vehicle? vehicle) {
    final base = vehicle?.displayName.trim().isNotEmpty == true
        ? vehicle!.displayName.trim()
        : 'Chat Session';
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$base • $y-$m-$d';
  }

  Future<void> _pickVehicle(
    BuildContext context,
    List<Vehicle> vehicles,
  ) async {
    final currentId = _selectedVehicleId ?? vehicles.first.id;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BorderRadiusValues.xl),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Vehicle',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                for (final v in vehicles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      v.id == currentId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: AppColors.secondary,
                    ),
                    title: Text(v.displayName),
                    subtitle: Text(v.plateNumber),
                    onTap: () => Navigator.of(ctx).pop(v.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null || picked == _selectedVehicleId) return;
    setState(() => _selectedVehicleId = picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listenWhen: (prev, curr) =>
          prev.messages.length != curr.messages.length ||
          prev.error != curr.error,
      listener: (context, state) {
        if (state.messages.isNotEmpty) {
          _scrollToBottom();
        }
        final err = state.error?.trim();
        if (err != null && err.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        }
      },
      builder: (context, state) {
        final vehiclesState = context.watch<VehiclesBloc>().state;
        final vehicles = vehiclesState is VehiclesLoaded
            ? vehiclesState.vehicles
            : const <Vehicle>[];
        if (_selectedVehicleId == null && vehicles.isNotEmpty) {
          final pref = widget.initialVehicleId?.trim();
          if (pref != null &&
              pref.isNotEmpty &&
              vehicles.any((v) => v.id == pref)) {
            _selectedVehicleId = pref;
          } else {
            _selectedVehicleId = vehicles.first.id;
          }
        }
        final selectedVehicle = _currentSelectedVehicle(context);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('AI Assistant'),
                if (selectedVehicle != null)
                  Text(
                    selectedVehicle.displayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            actions: [
              if (vehicles.isNotEmpty)
                IconButton(
                  tooltip: 'Select vehicle',
                  onPressed: () => _pickVehicle(context, vehicles),
                  icon: const Icon(Icons.directions_car_outlined),
                ),
              IconButton(
                tooltip: 'History',
                onPressed: _openHistory,
                icon: const Icon(Icons.history),
              ),
              IconButton(
                tooltip: 'New chat',
                onPressed: _startNewChat,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: Column(
            children: [
              if (state.loadingOlder)
                const Padding(
                  padding: EdgeInsets.only(top: Spacing.sm),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Expanded(
                child: state.messagesLoading && state.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels <= 60 &&
                              state.hasMore &&
                              !state.loadingOlder) {
                            context.read<AiChatBloc>().add(
                              const AiOlderMessagesRequested(),
                            );
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(Spacing.md),
                          itemCount: state.messages.isEmpty
                              ? 1
                              : state.messages.length,
                          itemBuilder: (context, index) {
                            if (state.messages.isEmpty) {
                              return _WelcomeBubble(
                                text:
                                    "Hello! I'm your CarCare AI assistant. Ask about maintenance, diagnostics, or your vehicle.",
                              );
                            }
                            final m = state.messages[index];
                            return _MessageBubble(message: m);
                          },
                        ),
                      ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.md,
                    Spacing.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Ask me anything...',
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.sm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                BorderRadiusValues.lg,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                BorderRadiusValues.lg,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                BorderRadiusValues.lg,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: state.sending ? null : _send,
                          child: state.sending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Makes plain AI replies readable as Markdown: breaks inline "1. … 2. …" into blocks.
String _assistantMarkdownData(String raw) {
  var t = raw.replaceAll('\r\n', '\n').trim();
  if (t.isEmpty) return t;
  // Convert inline "1. ... 2. ..." into proper numbered list lines.
  t = t.replaceAllMapped(RegExp(r'(?<=[^\n])\s+(?=\d+\.\s)'), (_) => '\n');
  // Convert inline "- ..." blocks into real markdown bullet lines.
  t = t.replaceAllMapped(RegExp(r':\s*-\s+'), (_) => ':\n- ');
  t = t.replaceAllMapped(RegExp(r'(?<=[^\n])\s+-\s+'), (_) => '\n- ');
  // If model returns one huge paragraph, split by sentence for easier scanning.
  if (!t.contains('\n') && t.length > 220) {
    t = t.replaceAllMapped(RegExp(r'(?<=[.!?])\s+(?=[A-Z])'), (_) => '\n');
  }
  return t;
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        ),
        child: MarkdownBody(
          data: _assistantMarkdownData(text),
          selectable: true,
          styleSheet: _markdownStyleSheet(
            context,
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

MarkdownStyleSheet _markdownStyleSheet(BuildContext context, TextStyle base) {
  final theme = Theme.of(context);
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: base.copyWith(height: 1.45),
    pPadding: const EdgeInsets.only(bottom: Spacing.sm),
    h1: base.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    h2: base.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
    h3: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    listBullet: base,
    listIndent: Spacing.md + Spacing.xs,
    blockSpacing: Spacing.sm,
    code: base.copyWith(
      fontFamily: 'monospace',
      fontSize: (base.fontSize ?? 14) * 0.92,
      backgroundColor: AppColors.surfaceMuted.withValues(alpha: 0.6),
    ),
    codeblockDecoration: BoxDecoration(
      color: AppColors.surfaceMuted.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(BorderRadiusValues.sm),
    ),
    codeblockPadding: const EdgeInsets.all(Spacing.sm),
    a: base.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    ),
    strong: base.copyWith(fontWeight: FontWeight.w700),
    em: base.copyWith(fontStyle: FontStyle.italic),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiMessageModel message;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    final bg = user ? AppColors.secondary : AppColors.surface;
    final fg = user ? AppColors.textOnPrimary : AppColors.textPrimary;
    final baseStyle = AppTextStyles.bodyMedium.copyWith(color: fg);
    final assistantLabelStyle = AppTextStyles.labelSmall.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
        padding: EdgeInsets.fromLTRB(
          Spacing.md,
          user ? Spacing.md : Spacing.sm,
          Spacing.md,
          Spacing.md,
        ),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
          border: user ? null : Border.all(color: AppColors.border),
        ),
        child: user
            ? Text(message.content, style: baseStyle)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(
                            BorderRadiusValues.circular,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text('AI Assistant', style: assistantLabelStyle),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  MarkdownBody(
                    data: _assistantMarkdownData(message.content),
                    selectable: true,
                    styleSheet: _markdownStyleSheet(context, baseStyle),
                  ),
                ],
              ),
      ),
    );
  }
}
