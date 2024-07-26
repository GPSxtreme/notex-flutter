// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/util_repository.dart';
import 'package:notex/presentation/blocs/settings/settings_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';
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
  bool _isSendingPasswordResetLink = false;
  bool _isSendingEmailVerificationLink = false;

  Widget label(String label) => Padding(
        padding: EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md),
        child: Text(
          label,
          style: AppText.textBase.copyWith(color: AppColors.mutedForeground),
        ),
      );

  Widget _switchListTile(
          {required String title,
          required String subtitle,
          required bool value,
          required void Function(bool) onChanged}) =>
      SwitchListTile(
        title: Text(
          title,
          style: AppText.textLgSemiBold,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            subtitle,
            style: AppText.textBase.copyWith(color: AppColors.mutedForeground),
          ),
        ),
        value: value,
        onChanged: onChanged,
      );

  Widget _iconListTile(
          {required String title,
          required String subtitle,
          required void Function() onTap,
          Widget? leading,
          required IconData icon}) =>
      ListTile(
        leading: leading ??
            Icon(
              icon,
              size: AppSpacing.iconSize2Xl,
              color: AppColors.mutedForeground,
            ),
        onTap: onTap,
        title: Text(
          title,
          style: AppText.textLgSemiBold,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            subtitle,
            style: AppText.textBase.copyWith(color: AppColors.mutedForeground),
          ),
        ),
      );

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
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: settingsBloc,
      listenWhen: (previous, current) => current is SettingsActionState,
      buildWhen: (previous, current) => current is! SettingsActionState,
      listener: (context, state) async {
        if (state is SettingsSnackBarAction) {
          kSnackBar(context, state.reason);
        } else if (state is SettingsUserLogoutAction) {
          bool? response = await CommonWidgets.commonAlertDialog(context,
              title: state.title ?? "Logout?",
              body: state.body ?? "you will be redirected to login page.",
              agreeLabel: state.agreeLabel ?? 'Logout',
              denyLabel: state.disagreeLabel ?? 'Cancel',
              isBarrierDismissible: state.isBarrierDismissible,
              isSingleBtn: state.isSingleButton);
          if (response == true) {
            GoRouter.of(context).goNamed(AppRouteConstants.loginRouteName);
          }
        } else if (state is SettingsDeleteAllNotesAction) {
          bool? res = await CommonWidgets.commonAlertDialog(context,
              title: "Delete all notes?",
              body: "All locally saved notes will be deleted.",
              agreeLabel: 'continue',
              denyLabel: 'cancel');
          if (res == true) {
            await LOCAL_DB.dropNotes().then((_) {
              GoRouter.of(context).goNamed(AppRouteConstants.splashRouteName);
            });
          }
        } else if (state is SettingsDeleteAllTodosAction) {
          bool? res = await CommonWidgets.commonAlertDialog(context,
              title: "Delete all todos?",
              body: "All locally saved todos will be deleted.",
              agreeLabel: 'continue',
              denyLabel: 'cancel');
          if (res == true) {
            await LOCAL_DB.dropTodos().then((_) {
              GoRouter.of(context).goNamed(AppRouteConstants.splashRouteName);
            });
          }
        } else if (state is SettingsRedirectToGithubAction) {
          await UtilRepository.launchLink(
              'https://github.com/GPSxtreme/notex-flutter');
        } else if (state is SettingsRedirectToGithubBugReportAction) {
          await UtilRepository.launchLink(
              'https://github.com/GPSxtreme/notex-flutter/issues/new/choose');
        } else if (state is SettingsRedirectToGithubRequestFeatureAction) {
          await UtilRepository.launchLink(
              'https://github.com/GPSxtreme/notex-flutter/issues/new/choose');
        } else if (state is SettingsRedirectToDevSiteAction) {
          await UtilRepository.launchLink('https://gpsxtre.me/');
        } else if (state is SettingsUserAccountDeletionAction) {
          await UtilRepository.launchLink(
              "$apiEndPoint/user/requestAccountDeletion");
        } else if (state is SettingsRedirectToDevMailAction) {
          await UtilRepository.launchEmail(
              emailAddresses: ['notexgps@gmail.com'],
              subject: 'Notex:query',
              body: '---query here---');
        } else if (state is SettingsCheckForAppUpdateAction) {
          bool response = await UtilRepository.checkForUpdate();
          if (!response) {
            kSnackBar(context, "No updates found");
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md),
                  child: IconButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.transparent),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                );
              },
            ),
            title: Text(
              "Settings",
              style: AppText.textXlBold,
            ),
          ),
          body: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: state is! SettingsFetchedState
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (state is SettingsFetchingState) ...[
                    const Center(
                      child: SpinKitRing(
                        lineWidth: 3.0,
                        color: AppColors.primary,
                      ),
                    )
                  ] else if (state is SettingsFetchingFailedState) ...[
                    Center(
                      child: Text(
                        'Something went wrong \n ${state.reason}',
                        textAlign: TextAlign.center,
                      ),
                    )
                  ] else if (state is SettingsFetchedState) ...[
                    ListTileTheme(
                      horizontalTitleGap: 10,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label('Sync Settings'),
                          _switchListTile(
                              title: 'Auto sync',
                              subtitle:
                                  'This enables auto-sync for both notes and todos. Auto sync must be enabled for removal of note or todo in cloud',
                              value: state.isAutoSyncEnabled,
                              onChanged: (value) async {
                                settingsBloc
                                    .add(SettingsSetAutoSyncEvent(value));
                              }),
                          _switchListTile(
                              title: 'Prefetch cloud notes',
                              subtitle:
                                  'This enables prefetch of cloud notes on startup',
                              value: state.isNotesOnlinePrefetchEnabled,
                              onChanged: (value) {
                                settingsBloc.add(
                                    SettingsSetPrefetchCloudNotesEvent(value));
                              }),
                          _switchListTile(
                              title: 'Prefetch cloud todos',
                              subtitle:
                                  'This enables prefetch of cloud todos on startup',
                              value: state.isTodosOnlinePrefetchEnabled,
                              onChanged: (value) {
                                settingsBloc.add(
                                    SettingsSetPrefetchCloudTodosEvent(value));
                              }),
                          label('Data Management'),
                          _iconListTile(
                              title: 'Delete all notes',
                              subtitle:
                                  'This will remove all the notes locally saved. Notes synced to cloud will not be affected',
                              onTap: () {
                                settingsBloc.add(SettingsDeleteAllNotesEvent());
                              },
                              icon: Icons.delete_rounded),
                          _iconListTile(
                              title: 'Delete all todos',
                              subtitle:
                                  'This will remove all the todos locally saved. Todos synced to cloud will not be affected',
                              onTap: () {
                                settingsBloc.add(SettingsDeleteAllTodosEvent());
                              },
                              icon: Icons.delete_rounded),
                          label('Security Settings'),
                          _switchListTile(
                              title: 'App lock',
                              subtitle: 'Sets up app lock to enter app',
                              value: state.isAppLockEnabled,
                              onChanged: (value) {
                                settingsBloc
                                    .add(SettingsSetAppLockEvent(value));
                              }),
                          _switchListTile(
                              title: 'Lock hidden notes',
                              subtitle:
                                  'Sets up app lock to access hidden notes',
                              value: state.isHiddenNotesLockEnabled,
                              onChanged: (value) {
                                settingsBloc.add(
                                    SettingsSetHiddenNotesLockEvent(value));
                              }),
                          _switchListTile(
                              title: 'Lock deleted notes',
                              subtitle:
                                  'Sets up app lock to access deleted notes',
                              value: state.isDeletedNotesLockEnabled,
                              onChanged: (value) {
                                settingsBloc.add(
                                    SettingsSetDeletedNotesLockEvent(value));
                              }),
                          _switchListTile(
                              title: 'Biometric only',
                              subtitle:
                                  'Prevent authentications from using non-biometric local authentication such as pin, passcode, or pattern',
                              value: state.isBiometricOnly,
                              onChanged: (value) async {
                                settingsBloc
                                    .add(SettingsSetBiometricOnlyEvent(value));
                              }),
                          label('About app'),
                          _iconListTile(
                              title: 'Checkout developer',
                              subtitle: 'Made with ❤️ by prudhvi suraaj',
                              onTap: () {
                                settingsBloc
                                    .add(SettingsRedirectToDevSiteEvent());
                              },
                              icon: Icons.engineering_rounded),
                          _iconListTile(
                            title: 'Open source',
                            subtitle: 'Check out code & make contributions',
                            onTap: () => settingsBloc
                                .add(SettingsRedirectToGithubEvent()),
                            icon: Ionicons.logo_github,
                          ),
                          _iconListTile(
                            title: 'Report a bug',
                            subtitle:
                                'Help us fix issues by reporting in app bugs',
                            onTap: () => settingsBloc
                                .add(SettingsRedirectToGithubBugReportEvent()),
                            icon: Icons.bug_report_outlined,
                          ),
                          _iconListTile(
                            title: 'Request feature',
                            subtitle: 'Request for a desired feature on github',
                            onTap: () => settingsBloc.add(
                                SettingsRedirectToGithubRequestFeatureEvent()),
                            icon: Icons.device_hub_outlined,
                          ),
                          _iconListTile(
                            title: 'Contact',
                            subtitle: 'Contact us for any problems related',
                            onTap: () => settingsBloc
                                .add(SettingsRedirectToDevMailEvent()),
                            icon: Icons.mail_outline,
                          ),
                          if (Platform.isAndroid)
                            _iconListTile(
                              title: 'Updates',
                              subtitle: 'Check for app updates',
                              onTap: () => settingsBloc
                                  .add(SettingsCheckForAppUpdatesEvent()),
                              icon: Icons.update,
                            ),
                          label('Account Management'),
                          if (!USER.data!.isEmailVerified)
                            _iconListTile(
                              leading: !_isSendingEmailVerificationLink
                                  ? Icon(
                                      Ionicons.alert_circle_outline,
                                      color: AppColors.mutedForeground,
                                      size: AppSpacing.iconSize2Xl,
                                    )
                                  : SizedBox(
                                      width: AppSpacing.iconSize2Xl,
                                      height: AppSpacing.iconSize2Xl,
                                      child: const SpinKitRing(
                                          color: AppColors.primary,
                                          lineWidth: 4.0)),
                              icon: Icons.verified_user,
                              onTap: !_isSendingEmailVerificationLink
                                  ? () {
                                      setState(() {
                                        _isSendingEmailVerificationLink = true;
                                      });
                                      settingsBloc.add(
                                          SettingsUserAccountVerifyEvent());
                                    }
                                  : () {},
                              title: 'Verify account',
                              subtitle:
                                  'Secure your account by verifying your email.\nPassword can only be reset if the account is verified',
                            ),
                          if (USER.data!.isEmailVerified)
                            _iconListTile(
                              leading: !_isSendingPasswordResetLink
                                  ? Icon(
                                      Icons.lock_reset,
                                      color: AppColors.mutedForeground,
                                      size: AppSpacing.iconSize2Xl,
                                    )
                                  : SizedBox(
                                      width: AppSpacing.iconSize2Xl,
                                      height: AppSpacing.iconSize2Xl,
                                      child: const SpinKitRing(
                                          color: AppColors.primary,
                                          lineWidth: 4.0)),
                              icon: Icons.lock_reset,
                              onTap: !_isSendingPasswordResetLink
                                  ? () {
                                      setState(() {
                                        _isSendingPasswordResetLink = true;
                                      });
                                      settingsBloc.add(
                                          SettingsUserPasswordResetEvent());
                                    }
                                  : () {},
                              title: 'Reset password',
                              subtitle:
                                  'You will be sent a password reset link to your registered email',
                            ),
                          _iconListTile(
                            title: 'Account deletion',
                            subtitle:
                                'You will be redirected to account deletion page',
                            onTap: () => settingsBloc
                                .add(SettingsUserAccountDeletionEvent()),
                            icon: Icons.account_box,
                          ),
                          _iconListTile(
                            title: 'Logout',
                            subtitle: 'You will be redirected to login screen',
                            onTap: () =>
                                settingsBloc.add(SettingsUserLogoutEvent()),
                            icon: Icons.logout_rounded,
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
