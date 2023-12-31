// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/core/config/api_routes.dart';
import 'package:notex/core/repositories/util_repository.dart';
import 'package:notex/presentation/blocs/settings/settings_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(label,
            style: kAppFont.copyWith(
                fontSize: 17, color: kWhite, fontWeight: FontWeight.w600)),
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
        } else if(state is SettingsDeleteAllNotesAction){
          bool? res = await CommonWidgets.commonAlertDialog(context, title: "Delete all notes?", body: "All locally saved notes will be deleted.", agreeLabel: 'continue', denyLabel: 'cancel');
          if(res == true){
            await LOCAL_DB.dropNotes().then((_) {
              GoRouter.of(context)
                  .goNamed(AppRouteConstants.splashRouteName);
            });
          }
        } else if(state is SettingsDeleteAllTodosAction){
          bool? res = await CommonWidgets.commonAlertDialog(context, title: "Delete all todos?", body: "All locally saved todos will be deleted.", agreeLabel: 'continue', denyLabel: 'cancel');
          if(res == true){
            await LOCAL_DB.dropTodos().then((_) {
              GoRouter.of(context)
                  .goNamed(AppRouteConstants.splashRouteName);
            });
          }
        } else if(state is SettingsRedirectToGithubAction){
          await UtilRepository.launchLink('https://github.com/GPSxtreme/notex-flutter');
        } else if(state is SettingsRedirectToGithubBugReportAction){
          await UtilRepository.launchLink('https://github.com/GPSxtreme/notex-flutter/issues/new/choose');
        }else if(state is SettingsRedirectToGithubRequestFeatureAction){
          await UtilRepository.launchLink('https://github.com/GPSxtreme/notex-flutter/issues/new/choose');
        } else if(state is SettingsRedirectToDevSiteAction){
          await UtilRepository.launchLink('https://prudhvisuraaj.me/');
        }else if(state is SettingsUserAccountDeletionAction){
          await UtilRepository.launchLink("$apiEndPoint/user/requestAccountDeletion");
        } else if(state is SettingsRedirectToDevMailAction){
          await UtilRepository.launchEmail(emailAddresses: ['contact@prudhvisuraaj.me'],subject: 'Notex:query',body: '---query here---');
        } else if(state is SettingsCheckForAppUpdateAction){
          bool response = await UtilRepository.checkForUpdate();
          if(!response){
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
              style: kAppFont,
            ),
            backgroundColor: kPageBgStart,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: kPageBgGradient),
            child: Material(
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
                          color: kPinkD1,
                        ),
                      )
                    ] else if (state is SettingsFetchingFailedState) ...[
                      Center(
                        child: Text(
                          'Something went wrong \n ${state.reason}',
                          style: kAppFont,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ] else if (state is SettingsFetchedState) ...[
                      ListTileTheme(
                        textColor: kWhite,
                        iconColor: kPinkD1,
                        horizontalTitleGap: 10,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label('Sync Settings'),
                            ListTile(
                              leading: const Icon(
                                Icons.sync,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Auto sync',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'This enables auto-sync for both notes and todos. Auto sync must be enabled for removal of note or todo in cloud',
                                style: kAppFont.copyWith(
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
                            ListTile(
                              leading: const Icon(
                                Icons.cloud_download_outlined,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Prefetch cloud notes',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'This enables prefetch of cloud notes on startup',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isNotesOnlinePrefetchEnabled,
                                onChanged: (value) {
                                  settingsBloc.add(
                                      SettingsSetPrefetchCloudNotesEvent(
                                          value));
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.cloud_download_outlined,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Prefetch cloud todos',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'This enables prefetch of cloud todos on startup',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isTodosOnlinePrefetchEnabled,
                                onChanged: (value) {
                                  settingsBloc.add(
                                      SettingsSetPrefetchCloudTodosEvent(
                                          value));
                                },
                              ),
                            ),
                            label('Data Management'),
                            ListTile(
                              splashColor: kPinkD1,
                              leading: const Icon(
                                Icons.delete_outline,
                                color: kPinkD1,
                                size: 35,
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsDeleteAllNotesEvent());
                              },
                              title: Text(
                                'Delete all notes',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'This will remove all the notes locally saved. Notes synced to cloud will not be affected',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                            ),
                            ListTile(
                              splashColor: kPinkD1,
                              leading: const Icon(
                                Icons.delete_outline,
                                color: kPinkD1,
                                size: 35,
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsDeleteAllTodosEvent());
                              },
                              title: Text(
                                'Delete all todos',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'This will remove all the todos locally saved. Todos synced to cloud will not be affected',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                            ),
                            label('Security Settings'),
                            ListTile(
                              leading: const Icon(
                                Icons.phonelink_lock_outlined,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'App lock',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Sets up app lock to enter app',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isAppLockEnabled,
                                onChanged: (value) {
                                  settingsBloc
                                      .add(SettingsSetAppLockEvent(value));
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.lock,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Lock hidden notes',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Sets up app lock to access hidden notes',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isHiddenNotesLockEnabled,
                                onChanged: (value) {
                                  settingsBloc.add(
                                      SettingsSetHiddenNotesLockEvent(value));
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.lock,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Lock deleted notes',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Sets up app lock to access deleted notes',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isDeletedNotesLockEnabled,
                                onChanged: (value) {
                                  settingsBloc.add(
                                      SettingsSetDeletedNotesLockEvent(value));
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.fingerprint_rounded,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Biometric only',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Prevent authentications from using non-biometric local authentication such as pin, passcode, or pattern',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              trailing: Switch(
                                activeColor: kPink,
                                activeTrackColor: kPinkD1,
                                inactiveThumbColor: kPinkD1,
                                inactiveTrackColor: kPinkD2,
                                value: state.isBiometricOnly,
                                onChanged: (value) async {
                                  settingsBloc.add(
                                      SettingsSetBiometricOnlyEvent(value));
                                },
                              ),
                            ),
                            label('About app'),
                            ListTile(
                              leading: const Icon(
                                Icons.engineering,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Checkout developer',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Made with ❤️ by prudhvi suraaj',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsRedirectToDevSiteEvent());
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Ionicons.logo_github,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Open source',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Check out code & make contributions',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsRedirectToGithubEvent());
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.bug_report_outlined,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Report a bug',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Help us fix issues by reporting in app bugs',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsRedirectToGithubBugReportEvent());
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.device_hub_outlined,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Request feature',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Request for a desired feature on github',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsRedirectToGithubRequestFeatureEvent());
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.mail_outline,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Contact',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Contact us for any problems related',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsRedirectToDevMailEvent());
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.update,
                                color: kPinkD1,
                                size: 35,
                              ),
                              title: Text(
                                'Updates',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'Check for app updates',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                              onTap: (){
                                settingsBloc.add(SettingsCheckForAppUpdatesEvent());
                              },
                            ),
                            label('Account Management'),
                            if (!USER.data!.isEmailVerified)
                              ListTile(
                                splashColor: kPinkD1,
                                leading: !_isSendingEmailVerificationLink
                                    ? const Icon(
                                        Ionicons.alert_circle_outline,
                                        color: Colors.yellow,
                                        size: 35,
                                      )
                                    : const SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: SpinKitRing(
                                            color: kPinkD1, lineWidth: 4.0)),
                                onTap: !_isSendingEmailVerificationLink
                                    ? () {
                                        setState(() {
                                          _isSendingEmailVerificationLink =
                                              true;
                                        });
                                        settingsBloc.add(
                                            SettingsUserAccountVerifyEvent());
                                      }
                                    : null,
                                title: Text(
                                  'Verify account',
                                  style: kAppFont.copyWith(fontSize: 15),
                                ),
                                subtitle: Text(
                                  'Secure your account by verifying your email.\nPassword can only be reset if the account is verified',
                                  style: kAppFont.copyWith(
                                      color: kWhite75, fontSize: 12),
                                ),
                              ),
                            if (USER.data!.isEmailVerified)
                              ListTile(
                                splashColor: kPinkD1,
                                leading: !_isSendingPasswordResetLink
                                    ? const Icon(
                                        Icons.lock_reset,
                                        color: kPinkD1,
                                        size: 35,
                                      )
                                    : const SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: SpinKitRing(
                                            color: kPinkD1, lineWidth: 4.0)),
                                onTap: !_isSendingPasswordResetLink
                                    ? (){
                                        setState(() {
                                          _isSendingPasswordResetLink = true;
                                        });
                                        settingsBloc.add(
                                            SettingsUserPasswordResetEvent());
                                      }
                                    : null,
                                title: Text(
                                  'Reset password',
                                  style: kAppFont.copyWith(fontSize: 15),
                                ),
                                subtitle: Text(
                                  'You will be sent a password reset link to your registered email',
                                  style: kAppFont.copyWith(
                                      color: kWhite75, fontSize: 12),
                                ),
                              ),
                            ListTile(
                              splashColor: kPinkD1,
                              leading: const Icon(
                                Icons.account_box,
                                color: kPinkD1,
                                size: 35,
                              ),
                              onTap: () {
                                settingsBloc.add(SettingsUserAccountDeletionEvent());
                              },
                              title: Text(
                                'Account deletion',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'You will be redirected to account deletion page',
                                style: kAppFont.copyWith(
                                    color: kWhite75, fontSize: 12),
                              ),
                            ),
                            ListTile(
                              splashColor: kPinkD1,
                              leading: const Icon(
                                Icons.logout_rounded,
                                color: kPinkD1,
                                size: 35,
                              ),
                              onTap: () {
                                settingsBloc.add(SettingsUserLogoutEvent());
                              },
                              title: Text(
                                'Logout',
                                style: kAppFont.copyWith(fontSize: 15),
                              ),
                              subtitle: Text(
                                'You will be redirected to login screen',
                                style: kAppFont.copyWith(
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
          ),
        );
      },
    );
  }
}
