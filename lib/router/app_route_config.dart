import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/pages/create_user_profile.dart';
import 'package:notex/presentation/pages/register.dart';
import 'package:notex/presentation/pages/splash.dart';
import 'package:notex/router/app_route_constants.dart';
import '../presentation/pages/home.dart';
import '../presentation/pages/login.dart';
import '../presentation/pages/notes.dart';
import '../presentation/pages/todos.dart';

class MyAppRouter {
  static GoRouter getRouter(bool isAuth) {
    // private navigators
    final rootNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
        initialLocation: '/',
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
          GoRoute(
              name: AppRouteConstants.homeRouteName,
              path: '/home',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return const MaterialPage(child: HomePage());
              },
            routes: [
              GoRoute(
                name: AppRouteConstants.notesRouteName,
                path: 'notes',
                pageBuilder:(BuildContext context, GoRouterState state) {
                  return const MaterialPage(child: NotesPage());
                }
              ),
              GoRoute(
                name: AppRouteConstants.todosRouteName,
                path: 'todos',
                pageBuilder:(BuildContext context, GoRouterState state) {
                  return const MaterialPage(child: TodosPage());
                }
              ),
            ]
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
