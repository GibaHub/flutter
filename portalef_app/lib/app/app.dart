import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme.dart';
import 'router.dart';

class PortalEFApp extends ConsumerWidget {
  const PortalEFApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PortalEF',
      debugShowCheckedModeBanner: false,
      theme: PortalEFTheme.light(),
      routerConfig: router,
    );
  }
}
