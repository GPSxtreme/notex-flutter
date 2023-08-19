// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/presentation/blocs/settings/settings_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/widgets/common_widgets.dart';
import 'package:notex/router/app_route_constants.dart';

import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsBloc settingsBloc = SettingsBloc();

  @override
  void initState() {
    super.initState();
    settingsBloc.add(SettingsInitialEvent());
  }

  @override
  void dispose() {
    settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: settingsBloc,
      listenWhen: (previous, current) => current is SettingsActionState,
      buildWhen: (previous, current) => current is! SettingsActionState,
      listener: (context, state) async {
        if (state is SettingsSnackBarState) {
          kSnackBar(context, state.reason);
        } else if (state is SettingsUserLogoutState) {
          bool? response = await CommonWidgets.commonAlertDialog(
            context,
            title: state.title ?? "Logout?",
            body: state.body ?? "you will be redirected to login page.",
            agreeLabel: state.agreeLabel ?? 'Logout',
            denyLabel:  state.disagreeLabel ??'Cancel',
            isBarrierDismissible: state.isBarrierDismissible,
            isSingleBtn: state.isSingleButton
          );
          if (response == true) {
            GoRouter.of(context).goNamed(AppRouteConstants.loginRouteName);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                );
              },
            ),
            title: Text(
              "Settings",
              style: kInter,
            ),
            backgroundColor: kPageBgStart,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: kPageBgGradient),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: state is! SettingsFetchedState
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (state is SettingsFetchingState) ...[
                    const Center(
                      child: SpinKitRing(
                        lineWidth: 3.0,
                        color: kPinkD1,
                      ),
                    )
                  ] else if (state is SettingsFetchingFailedState) ...[
                    Center(
                      child: Text(
                        'Something went wrong \n ${state.reason}',
                        style: kInter,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ] else if (state is SettingsFetchedState) ...[
                    ListTileTheme(
                      textColor: kWhite,
                      iconColor: kPinkD1,
                      horizontalTitleGap: 5,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Column(
                        children: [
                          if (!USER.data!.isEmailVerified)
                            ListTile(
                              splashColor: kPinkD1,
                              leading: const Icon(
                                Ionicons.alert_circle_outline,
                                color: Colors.yellow,
                                size: 30,
                              ),
                              onTap: () {
                                settingsBloc.add(SettingsUserAccountVerifyEvent());
                              },
                              title: Text(
                                'Verify account',
                                style: kInter.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Secure your account by verifying your email.\nPassword can only be reset if the account is verified.',
                                style: kInter.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                            ),
                          ListTile(
                            leading: const Icon(
                              Icons.sync,
                              color: kPinkD1,
                              size: 30,
                            ),
                            title: Text(
                              'Enable auto-sync',
                              style: kInter.copyWith(fontSize: 15),
                            ),
                            subtitle: Text(
                              'This enables auto-sync for both notes and todos.',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            trailing: Switch(
                              activeColor: kPink,
                              activeTrackColor: kPinkD1,
                              inactiveThumbColor: kPinkD1,
                              inactiveTrackColor: kPinkD2,
                              value: state.isAutoSyncEnabled,
                              onChanged: (value) async {
                                settingsBloc
                                    .add(SettingsSetAutoSyncEvent(value));
                              },
                            ),
                          ),
                          if(USER.data!.isEmailVerified)
                          ListTile(
                            splashColor: kPinkD1,
                            leading: const Icon(
                              Icons.lock_reset,
                              color: kPinkD1,
                              size: 30,
                            ),
                            onTap: () {
                              settingsBloc.add(SettingsUserPasswordResetEvent());
                            },
                            title: Text(
                              'Reset password',
                              style: kInter.copyWith(fontSize: 15),
                            ),
                            subtitle: Text(
                              'You will be sent a password reset link to your registered email.',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                          ),
                          ListTile(
                            splashColor: kPinkD1,
                            leading: const Icon(
                              Icons.logout_rounded,
                              color: kPinkD1,
                              size: 30,
                            ),
                            onTap: () {
                              settingsBloc.add(SettingsUserLogoutEvent());
                            },
                            title: Text(
                              'Logout',
                              style: kInter.copyWith(fontSize: 15),
                            ),
                            subtitle: Text(
                              'You will be redirected to login screen',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
