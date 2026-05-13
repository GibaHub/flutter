import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/security/biometric_controller.dart';
import '../features/admin/presentation/admin_essays_page.dart';
import '../features/admin/presentation/admin_essay_submissions_page.dart';
import '../features/admin/presentation/admin_extra_activities_page.dart';
import '../features/admin/presentation/admin_extra_activity_submissions_page.dart';
import '../features/admin/presentation/admin_home_page.dart';
import '../features/admin/presentation/admin_users_page.dart';
import '../features/admin/presentation/admin_user_form_page.dart';
import '../features/admin/presentation/admin_groups_page.dart';
import '../features/admin/presentation/admin_group_form_page.dart';
import '../features/admin/presentation/admin_group_details_page.dart';
import '../features/admin/presentation/admin_contents_page.dart';
import '../features/admin/presentation/admin_content_form_page.dart';
import '../features/admin/presentation/admin_guardian_links_page.dart';
import '../features/admin/presentation/admin_guardian_manage_page.dart';
import '../features/admin/data/admin_repository.dart';
import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/parent/presentation/parent_home_page.dart';
import '../features/parent/presentation/report_card_page.dart';
import '../features/parent/presentation/parent_stats_page.dart';
import '../features/parent/presentation/parent_essays_page.dart';
import '../features/parent/presentation/parent_extra_activities_page.dart';
import '../features/student/domain/study_group.dart';
import '../features/student/presentation/content_study_page.dart';
import '../features/student/presentation/evaluation_result_page.dart';
import '../features/student/presentation/evaluation_take_page.dart';
import '../features/student/presentation/essay_take_page.dart';
import '../features/student/presentation/pdf_viewer_page.dart';
import '../features/student/presentation/practice_quiz_page.dart';
import '../features/student/presentation/student_essays_page.dart';
import '../features/student/presentation/student_extra_activities_page.dart';
import '../features/student/presentation/student_contents_page.dart';
import '../features/student/presentation/student_evaluations_page.dart';
import '../features/student/presentation/student_home_page.dart';
import '../features/student/presentation/student_shell.dart';
import '../features/student/presentation/extra_activity_take_page.dart';
import '../features/student/presentation/study_timer_page.dart';
import '../features/teacher/presentation/teacher_home_page.dart';
import '../features/teacher/presentation/teacher_groups_page.dart';
import '../features/teacher/presentation/teacher_evaluations_page.dart';
import '../features/teacher/presentation/teacher_question_banks_page.dart';
import '../features/teacher/presentation/teacher_shell.dart';
import '../features/ai/presentation/ai_chat_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthRefreshListenable(ref);
  ref.onDispose(authListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authAsync = authListenable.authValue;
      final biometricAsync = authListenable.biometricValue;

      if (authAsync.isLoading || biometricAsync.isLoading) {
        if (location == '/splash' || location == '/login') {
          return null;
        }
        return '/splash';
      }

      final session = authAsync.valueOrNull;
      if (session == null) {
        return location == '/login' ? null : '/login';
      }

      final biometric = biometricAsync.valueOrNull;
      final needsUnlock =
          (biometric?.enabled ?? false) && !(biometric?.unlocked ?? false);
      if (needsUnlock) {
        return location == '/splash' ? null : '/splash';
      }

      if (location == '/login' || location == '/splash') {
        return _homeForRole(session.user.role);
      }

      final role = session.user.role;
      if (location.startsWith('/admin') && role != UserRole.admin) {
        return _homeForRole(role);
      }
      if (location.startsWith('/responsavel') && role != UserRole.responsavel) {
        return _homeForRole(role);
      }
      if (location.startsWith('/aluno') && role != UserRole.aluno) {
        return _homeForRole(role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/ai/chat',
        builder: (context, state) {
          final studentIdRaw = state.uri.queryParameters['studentId'];
          final studentId = studentIdRaw != null ? int.tryParse(studentIdRaw) : null;
          return AiChatPage(studentId: studentId);
        },
      ),
      GoRoute(
        path: '/pdf',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'];
          return PdfViewerPage(url: url);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StudentShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aluno/home',
                builder: (context, state) => const StudentHomePage(),
              ),
              GoRoute(
                path: '/aluno/redacoes',
                builder: (context, state) => const StudentEssaysPage(),
                routes: [
                  GoRoute(
                    path: ':essayId',
                    builder: (context, state) {
                      final id = int.tryParse(
                        state.pathParameters['essayId'] ?? '',
                      );
                      if (id == null) {
                        return const Scaffold(
                          body: Center(child: Text('ID inválido')),
                        );
                      }
                      return EssayTakePage(essayId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/aluno/atividades-extras',
                builder: (context, state) => const StudentExtraActivitiesPage(),
                routes: [
                  GoRoute(
                    path: ':activityId',
                    builder: (context, state) {
                      final id = int.tryParse(
                        state.pathParameters['activityId'] ?? '',
                      );
                      if (id == null) {
                        return const Scaffold(
                          body: Center(child: Text('ID inválido')),
                        );
                      }
                      return ExtraActivityTakePage(activityId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aluno/conteudos',
                builder: (context, state) => const StudentContentsPage(),
                routes: [
                  GoRoute(
                    path: 'estudar',
                    builder: (context, state) {
                      final content = state.extra;
                      if (content is StudyContent) {
                        return ContentStudyPage(content: content);
                      }
                      return const Scaffold(
                        body: Center(child: Text('Conteúdo ausente')),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'praticar',
                    builder: (context, state) {
                      final content = state.extra;
                      if (content is StudyContent) {
                        return PracticeQuizPage(
                          contentId: content.id,
                          title: content.titulo,
                        );
                      }
                      return const Scaffold(
                        body: Center(child: Text('Conteúdo ausente')),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'pdf',
                    builder: (context, state) {
                      final url = state.uri.queryParameters['url'];
                      return PdfViewerPage(url: url);
                    },
                  ),
                  GoRoute(
                    path: 'timer',
                    builder: (context, state) {
                      final contentIdRaw =
                          state.uri.queryParameters['contentId'];
                      final contentId = int.tryParse(contentIdRaw ?? '');
                      return StudyTimerPage(contentId: contentId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aluno/avaliacoes',
                builder: (context, state) => const StudentEvaluationsPage(),
                routes: [
                  GoRoute(
                    path: ':evaluationId',
                    builder: (context, state) {
                      final id = int.tryParse(
                        state.pathParameters['evaluationId'] ?? '',
                      );
                      if (id == null) {
                        return const Scaffold(
                          body: Center(child: Text('ID inválido')),
                        );
                      }
                      return EvaluationTakePage(evaluationId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'resultado',
                        builder: (context, state) {
                          final id = int.tryParse(
                            state.pathParameters['evaluationId'] ?? '',
                          );
                          if (id == null) {
                            return const Scaffold(
                              body: Center(child: Text('ID inválido')),
                            );
                          }
                          return EvaluationResultPage(evaluationId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/responsavel',
        builder: (context, state) => const ParentHomePage(),
        routes: [
          GoRoute(
            path: 'boletim',
            builder: (context, state) {
              final studentIdRaw = state.uri.queryParameters['studentId'];
              final studentId = int.tryParse(studentIdRaw ?? '');
              return ReportCardPage(studentId: studentId);
            },
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) {
              final studentIdRaw = state.uri.queryParameters['studentId'];
              final studentId = int.tryParse(studentIdRaw ?? '');
              return ParentStatsPage(studentId: studentId);
            },
          ),
          GoRoute(
            path: 'redacoes',
            builder: (context, state) {
              final studentIdRaw = state.uri.queryParameters['studentId'];
              final studentId = int.tryParse(studentIdRaw ?? '');
              return ParentEssaysPage(studentId: studentId);
            },
          ),
          GoRoute(
            path: 'atividades-extras',
            builder: (context, state) {
              final studentIdRaw = state.uri.queryParameters['studentId'];
              final studentId = int.tryParse(studentIdRaw ?? '');
              return ParentExtraActivitiesPage(studentId: studentId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomePage(),
        routes: [
          GoRoute(
            path: 'redacoes',
            builder: (context, state) => const AdminEssaysPage(),
            routes: [
              GoRoute(
                path: ':essayId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['essayId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  return AdminEssaySubmissionsPage(essayId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'atividades-extras',
            builder: (context, state) => const AdminExtraActivitiesPage(),
            routes: [
              GoRoute(
                path: ':activityId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['activityId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  return AdminExtraActivitySubmissionsPage(activityId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'usuarios',
            builder: (context, state) => const AdminUsersPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) {
                  return const AdminUserFormPage(
                    userId: null,
                    initialUser: null,
                  );
                },
              ),
              GoRoute(
                path: ':userId',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['userId'] ?? '');
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  final extra = state.extra;
                  return AdminUserFormPage(
                    userId: id,
                    initialUser: extra is AdminUser ? extra : null,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'grupos',
            builder: (context, state) => const AdminGroupsPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder:
                    (context, state) => const AdminGroupFormPage(groupId: null),
              ),
              GoRoute(
                path: ':groupId/detalhes',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['groupId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  return AdminGroupDetailsPage(groupId: id);
                },
              ),
              GoRoute(
                path: ':groupId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['groupId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  return AdminGroupFormPage(groupId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'vinculos',
            builder: (context, state) => const AdminGuardianLinksPage(),
            routes: [
              GoRoute(
                path: ':guardianId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['guardianId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  return AdminGuardianManagePage(guardianId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'conteudos',
            builder: (context, state) => const AdminContentsPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) {
                  return const AdminContentFormPage(
                    contentId: null,
                    initialContent: null,
                  );
                },
              ),
              GoRoute(
                path: ':contentId',
                builder: (context, state) {
                  final id = int.tryParse(
                    state.pathParameters['contentId'] ?? '',
                  );
                  if (id == null) {
                    return const Scaffold(
                      body: Center(child: Text('ID inválido')),
                    );
                  }
                  final extra = state.extra;
                  return AdminContentFormPage(
                    contentId: id,
                    initialContent: extra is AdminContent ? extra : null,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TeacherShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/professor/home',
                builder: (context, state) => const TeacherHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/professor/grupos',
                builder: (context, state) => const TeacherGroupsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/professor/avaliacoes',
                builder: (context, state) => const TeacherEvaluationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/professor/bancos',
                builder: (context, state) => const TeacherQuestionBanksPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _homeForRole(UserRole role) {
  return switch (role) {
    UserRole.aluno => '/aluno/home',
    UserRole.responsavel => '/responsavel',
    UserRole.admin => '/admin',
    UserRole.professor => '/professor',
  };
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this.ref) {
    _authValue = ref.read(authControllerProvider);
    _biometricValue = ref.read(biometricControllerProvider);
    _authSubscription = ref.listen<AsyncValue<AuthSession?>>(
      authControllerProvider,
      (previous, next) {
        _authValue = next;
        notifyListeners();
      },
    );
    _biometricSubscription = ref.listen<AsyncValue<BiometricState>>(
      biometricControllerProvider,
      (previous, next) {
        _biometricValue = next;
        notifyListeners();
      },
    );
  }

  final Ref ref;
  late AsyncValue<AuthSession?> _authValue;
  late AsyncValue<BiometricState> _biometricValue;
  late ProviderSubscription<AsyncValue<AuthSession?>> _authSubscription;
  late ProviderSubscription<AsyncValue<BiometricState>> _biometricSubscription;

  AsyncValue<AuthSession?> get authValue => _authValue;
  AsyncValue<BiometricState> get biometricValue => _biometricValue;

  @override
  void dispose() {
    _authSubscription.close();
    _biometricSubscription.close();
    super.dispose();
  }
}
