import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/chat_screen.dart';
import '../presentation/screens/history_screen.dart';
import '../presentation/screens/therapies_screen.dart';
import '../presentation/screens/appointments_screen.dart';
import '../presentation/screens/orders_screen.dart';
import '../presentation/screens/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/therapies',
      builder: (context, state) => const TherapiesScreen(),
    ),
    GoRoute(
      path: '/appointments',
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/chat/:appointmentId',
      builder: (context, state) {
        final appointmentId = state.pathParameters['appointmentId']!;
        return ChatScreen(appointmentId: appointmentId);
      },
    ),
  ],
);
