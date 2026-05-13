import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/news_controller.dart';

class NewsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? newsItem;
  final bool isPromotionDefault;

  const NewsFormScreen({
    super.key,
    this.newsItem,
    this.isPromotionDefault = false,
  });

  @override
  State<NewsFormScreen> createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dateController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.newsItem != null) {
      _titleController.text = widget.newsItem!['title'];
      _subtitleController.text = widget.newsItem!['subtitle'] ?? '';
      _contentController.text = widget.newsItem!['content'] ?? '';
      _dateController.text =
          widget.newsItem!['publishedAt'] != null
              ? _formatDateDisplay(widget.newsItem!['publishedAt'])
              : '';
      _imageBytes = widget.newsItem!['imageBytes'];
    }
  }

  String _formatDateDisplay(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return isoString;
    }
  }

  String? _formatDateForApi(String displayDate) {
    try {
      final parts = displayDate.split('/');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      ).toIso8601String();
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.newsItem != null
              ? 'Admin - Editar Publicação'
              : 'Admin - Cadastro de Notícias',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.newsItem != null
                            ? "Editar Publicação"
                            : "Nova Publicação",
                        style:
                            isMobile
                                ? Theme.of(context).textTheme.headlineSmall
                                : Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _subtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtítulo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subtitles),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Data de Publicação',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _dateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            });
                          }
                        },
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            _imageBytes != null
                                ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: IconButton(
                                        onPressed:
                                            () => setState(
                                              () => _imageBytes = null,
                                            ),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _pickImage,
                                      child: const Text(
                                        "Upload de Banner (Imagem)",
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newsItem = {
                                'title': _titleController.text,
                                'subtitle': _subtitleController.text,
                                'content': _contentController.text,
                                'publishedAt': _formatDateForApi(
                                  _dateController.text,
                                ),
                                'imageBytes': _imageBytes,
                              };

                              if (widget.newsItem != null) {
                                context.read<NewsController>().updateNews(
                                  widget.newsItem!['id'],
                                  newsItem,
                                );
                              } else {
                                context.read<NewsController>().addNews(
                                  newsItem,
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.newsItem != null
                                        ? 'Alterações salvas com sucesso!'
                                        : 'Conteúdo publicado com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            widget.newsItem != null
                                ? "Salvar Alterações"
                                : "Publicar Conteúdo",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
