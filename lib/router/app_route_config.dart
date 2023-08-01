import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/pages/create_user_profile.dart';
import 'package:notex/presentation/pages/register.dart';
import 'package:notex/presentation/pages/splash.dart';
import 'package:notex/router/app_route_constants.dart';
import 'package:notex/router/router_transition_factory.dart';
import '../presentation/pages/home.dart';
import '../presentation/pages/login.dart';
import '../presentation/pages/notes.dart';
import '../presentation/pages/todos.dart';

class MyAppRouter {
  static GoRouter getRouter(bool isAuth) {
    // private navigators
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorNotesKey =
        GlobalKey<NavigatorState>(debugLabel: 'NotesShell');
    final shellNavigatorTodosKey =
        GlobalKey<NavigatorState>(debugLabel: 'TodosShell');

    return GoRouter(
        initialLocation: '/notes',
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
              name: AppRouteConstants.splashRouteName,
              path: '/',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return const MaterialPage(child: SplashPage());
              }),
          GoRoute(
              name: AppRouteConstants.loginRouteName,
              path: '/login',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return const MaterialPage(child: LoginPage());
              }),
          GoRoute(
              name: AppRouteConstants.registerRouteName,
              path: '/register',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return const MaterialPage(child: RegisterPage());
              }),
          GoRoute(
              name: AppRouteConstants.createUserProfileName,
              path: '/createUserProfile',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return const MaterialPage(child: CreateUserProfile());
              }),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              // the UI shell
              return HomePage(navigationShell: navigationShell);
            },
            branches: [
              // first branch (notes)
              StatefulShellBranch(
                navigatorKey: shellNavigatorNotesKey,
                routes: [
                  // top route inside branch
                  GoRoute(
                    name: AppRouteConstants.notesRouteName,
                    path: '/notes',
                    pageBuilder: (context, state) =>
                        RouterTransitionFactory.getTransitionPage(
                            context: context,
                            state: state,
                            child: const NotesPage(),
                            type: 'slide'),
                  ),
                ],
              ),
              // second branch (todos)
              StatefulShellBranch(
                navigatorKey: shellNavigatorTodosKey,
                routes: [
                  // top route inside branch
                  GoRoute(
                    name: AppRouteConstants.todosRouteName,
                    path: '/todos',
                    pageBuilder: (context, state) =>
                        RouterTransitionFactory.getTransitionPage(
                            context: context,
                            state: state,
                            child: const TodosPage(),
                            type: 'slide'),
                  ),
                ],
              ),
            ],
          ),
        ],
        redirect: (context, state) {
          // if(!isAuth){
          //   return context.namedLocation(AppRouteConstants.loginRouteName);
          // }else{
          //   return null;
          // }
          print(state.fullPath);
        });
  }
}
