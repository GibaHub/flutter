import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ai_repository.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key, this.studentId});

  final int? studentId;

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _messages.add(_ChatMessage(role: _ChatRole.user, text: text));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final repo = ref.read(aiRepositoryProvider);
      final res = await repo.analyze(
        message: text,
        studentId: widget.studentId,
      );
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            text: res.reply,
            suggestions: res.suggestions,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            text: 'Não consegui responder agora. Tente novamente.',
          ),
        );
      });
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openContent(AiSupportContent c) async {
    final url =
        c.pdfUrl ??
        c.videoUrl ??
        c.url ??
        '${ApiConfig.publicBaseUrl()}/api/contents/${c.id}';
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professor Virtual')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _IntroCard(studentId: widget.studentId);
                  }
                  final m = _messages[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MessageBubble(
                      message: m,
                      onOpenContent: _openContent,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Digite sua dúvida...',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primaryTeal.withValues(alpha: 0.9),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _loading ? null : _send,
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(PhosphorIconsRegular.paperPlaneTilt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(PhosphorIconsFill.sparkle, color: AppColors.primaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              studentId == null
                  ? 'Posso analisar seu progresso e sugerir um plano de estudo.'
                  : 'Posso analisar o progresso do aluno e sugerir um plano de estudo.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  _ChatMessage({required this.role, required this.text, this.suggestions});

  final _ChatRole role;
  final String text;
  final List<AiSupportContent>? suggestions;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onOpenContent});

  final _ChatMessage message;
  final void Function(AiSupportContent c) onOpenContent;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _ChatRole.user;
    final bg =
        isUser
            ? AppColors.primaryTeal.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.06);
    final border =
        isUser
            ? AppColors.primaryTeal.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.08);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(message.text),
              if ((message.suggestions ?? const []).isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Conteúdos sugeridos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...message.suggestions!
                    .take(3)
                    .map(
                      (c) =>
                          _ContentTile(item: c, onTap: () => onOpenContent(c)),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile({required this.item, required this.onTap});

  final AiSupportContent item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Icon(
              PhosphorIconsRegular.bookOpen,
              size: 18,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.materia,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.arrowSquareOut, size: 18),
          ],
        ),
      ),
    );
  }
}
