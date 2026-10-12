import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/expense_detail_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/home_shell.dart';
import '../screens/reports_screen.dart';
import '../screens/review_screen.dart';
import '../services/receipt_parser.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const ExpenseListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) {
        final parsed = state.extra as ParsedReceipt? ??
            const ParsedReceipt(merchant: '', rawText: '');
        return ReviewScreen(parsed: parsed);
      },
    ),
    GoRoute(
      path: '/expense/:id',
      builder: (context, state) {
        return ExpenseDetailScreen(expenseId: state.pathParameters['id']!);
      },
    ),
  ],
);
