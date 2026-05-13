import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_contents_page.dart';
import 'admin_scaffold.dart';

final adminContentByIdProvider = FutureProvider.family<AdminContent, int>((ref, id) async {
  return ref.watch(adminRepositoryProvider).getContentById(id: id);
});

class AdminContentFormPage extends ConsumerStatefulWidget {
  const AdminContentFormPage({super.key, required this.contentId, required this.initialContent});

  final int? contentId;
  final AdminContent? initialContent;

  @override
  ConsumerState<AdminContentFormPage> createState() => _AdminContentFormPageState();
}

class _AdminContentFormPageState extends ConsumerState<AdminContentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _materiaController = TextEditingController();
  final _categoriaController = TextEditingController(text: 'Aula');
  final _videoUrlController = TextEditingController();

  PlatformFile? _pdfFile;
  var _saving = false;
  var _prefilled = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _materiaController.dispose();
    _categoriaController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.contentId;
    final isCreate = id == null;
    final title = isCreate ? 'Novo conteúdo' : 'Editar conteúdo';

    final initial = widget.initialContent;
    if (initial != null) {
      _prefillIfNeeded(initial);
      return _buildForm(title: title, contentId: initial.id, isCreate: isCreate, existingPdfUrl: initial.pdfUrl);
    }

    if (isCreate) {
      return _buildForm(title: title, contentId: null, isCreate: true, existingPdfUrl: null);
    }

    final asyncContent = ref.watch(adminContentByIdProvider(id));
    return asyncContent.when(
      data: (content) {
        _prefillIfNeeded(content);
        return _buildForm(
          title: title,
          contentId: content.id,
          isCreate: false,
          existingPdfUrl: content.pdfUrl,
        );
      },
      error: (error, _) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text('Erro ao carregar conteúdo: $error')),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _prefillIfNeeded(AdminContent content) {
    if (_prefilled) return;
    _tituloController.text = content.titulo;
    _materiaController.text = content.materia;
    _categoriaController.text = (content.categoria ?? '').isEmpty ? 'Aula' : content.categoria!;
    _videoUrlController.text = content.videoUrl ?? '';
    _prefilled = true;
  }

  Widget _buildForm({
    required String title,
    required int? contentId,
    required bool isCreate,
    required String? existingPdfUrl,
  }) {
    return AdminScaffold(
      selectedIndex: 4,
      title: title,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Informe o título';
                    return null;
                  },
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _materiaController,
                  decoration: const InputDecoration(labelText: 'Matéria'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Informe a matéria';
                    return null;
                  },
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(labelText: 'URL do vídeo (opcional)'),
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                if ((existingPdfUrl?.isNotEmpty ?? false))
                  FilledButton.tonalIcon(
                    onPressed: _saving ? null : () => context.go('/pdf?url=${Uri.encodeComponent(existingPdfUrl!)}'),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Abrir PDF atual'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          final picked = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            withData: true,
                            type: FileType.custom,
                            allowedExtensions: const ['pdf'],
                          );
                          final file = (picked?.files.isNotEmpty ?? false) ? picked!.files.first : null;
                          if (file == null) return;
                          setState(() => _pdfFile = file);
                        },
                  icon: const Icon(Icons.upload_file),
                  label: Text(_pdfFile == null ? 'Anexar PDF (opcional)' : 'PDF: ${_pdfFile!.name}'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) return;
                          await _save(contentId: contentId, isCreate: isCreate);
                        },
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save({required int? contentId, required bool isCreate}) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final titulo = _tituloController.text.trim();
      final materia = _materiaController.text.trim();
      final categoria = _categoriaController.text.trim().isEmpty ? 'Aula' : _categoriaController.text.trim();
      final videoUrl = _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim();

      if (isCreate) {
        await repo.createContent(
          titulo: titulo,
          materia: materia,
          categoria: categoria,
          videoUrl: videoUrl,
          pdfFile: _pdfFile,
        );
      } else {
        await repo.updateContent(
          id: contentId!,
          titulo: titulo,
          materia: materia,
          categoria: categoria,
          videoUrl: videoUrl,
          pdfFile: _pdfFile,
        );
      }

      ref.invalidate(adminContentsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar: $e'), backgroundColor: AppColors.error),
        );
      }
      if (mounted) setState(() => _saving = false);
    }
  }
}
