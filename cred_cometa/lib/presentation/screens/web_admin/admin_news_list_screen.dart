import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/news_controller.dart';
import 'news_form_screen.dart';

class AdminNewsListScreen extends StatefulWidget {
  final bool onlyPromotions;

  const AdminNewsListScreen({super.key, this.onlyPromotions = false});

  @override
  State<AdminNewsListScreen> createState() => _AdminNewsListScreenState();
}

class _AdminNewsListScreenState extends State<AdminNewsListScreen> {
  @override
  Widget build(BuildContext context) {
    final newsController = context.watch<NewsController>();
    final allNews = newsController.news;
    final isMobile = MediaQuery.of(context).size.width < 900;

    final filteredNews = allNews;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          isMobile
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => NewsFormScreen(
                            isPromotionDefault: false,
                          ),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
              : null,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gerenciamento de Notícias",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Crie, edite e remova conteúdos do aplicativo.",
                        style: GoogleFonts.openSans(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => NewsFormScreen(
                                isPromotionDefault: false,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text("Nova Publicação"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ] else ...[
              // Mobile Header is simpler, maybe handled by AppBar in Layout or here
              Text(
                "Gerenciamento de Notícias",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: filteredNews.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredNews[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      title: Text(
                        item['title'],
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${item['subtitle'] ?? ''} • ${item['publishedAt']}",
                        style: GoogleFonts.openSans(fontSize: 12),
                      ),
                      trailing:
                          isMobile
                              ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                NewsFormScreen(newsItem: item),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDelete(context, item);
                                  }
                                },
                                itemBuilder:
                                    (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Text('Editar'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text(
                                              'Excluir',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          item['status'] == 'Ativo'
                                              ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                              : Colors.orange.withValues(
                                                alpha: 0.1,
                                              ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item['status'],
                                      style: TextStyle(
                                        color:
                                            item['status'] == 'Ativo'
                                                ? Colors.green
                                                : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  NewsFormScreen(newsItem: item),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _confirmDelete(context, item);
                                    },
                                  ),
                                ],
                              ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirmar Exclusão"),
            content: Text("Deseja realmente excluir '${item['title']}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  context.read<NewsController>().deleteNews(item['id']);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Item removido com sucesso!")));
                },
                child: const Text("Excluir", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
