import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/login/login_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/router/app_route_constants.dart';

import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginBloc loginBloc = LoginBloc();
  bool _hide = true;
  bool _rememberDevice = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: loginBloc,
      listenWhen: (previous, current) => current is LoginActionState,
      buildWhen: (previous, current) => current is! LoginActionState,
      listener: (context, state) {
        if (state is LoginNavigateToRegisterPageActionState) {
          GoRouter.of(context).pushNamed(AppRouteConstants.registerRouteName);
        } else if (state is LoginSuccessState) {
          GoRouter.of(context)
              .pushReplacementNamed(AppRouteConstants.homeRouteName);
        } else if (state is LoginFailedState) {
          kSnackBar(context, state.reason);
        } else if (state is LoginRedirectToCreateUserProfilePageAction) {
          GoRouter.of(context)
              .pushNamed(AppRouteConstants.createUserProfileName);
        } else if (state is LoginRedirectToPasswordResetPageAction) {
          GoRouter.of(context)
              .pushNamed(AppRouteConstants.passwordResetRouteName);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: -SizeConfig.blockSizeHorizontal! * 0.5,
                    child:
                        SvgPicture.asset('assets/svg/login_page_bg_decor.svg'),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 20,
                            ),
                            Text(
                              "Sign in to",
                            ),
                            Row(
                              children: [
                                Text(
                                  "your ",
                                ),
                                Text(
                                  "account",
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // go to register page
                                      loginBloc.add(
                                          LoginPageRegisterButtonClickedEvent());
                                    },
                                    child: Text(
                                      "Register ",
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 7,
                            ),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 3,
                            ),
                            TextField(
                              keyboardType: TextInputType.text,
                              controller: _passwordController,
                              obscureText: _hide,
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical,
                            ),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                      value: _rememberDevice,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _rememberDevice = value!;
                                        });
                                      }),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rememberDevice = !_rememberDevice;
                                    });
                                  },
                                  child: Text(
                                    "Remember device",
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 5,
                            ),
                            SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: state is! LoginLoadingSate
                                    ? () {
                                        // login user
                                        if (_emailController.text.isEmpty ||
                                            _passwordController.text.isEmpty) {
                                          kSnackBar(context,
                                              'Please fill in all fields');
                                        } else {
                                          loginBloc.add(
                                              LoginPageLoginButtonClickedEvent(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                  _rememberDevice));
                                        }
                                      }
                                    : null,
                                child: state is! LoginLoadingSate
                                    ? Text(
                                        "Login",
                                      )
                                    : SpinKitCircle(
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                            ),
                            GestureDetector(
                              onTap: () {
                                loginBloc.add(
                                    LoginPageForgotPasswordButtonClickedEvent());
                              },
                              child: RichText(
                                text: TextSpan(text: 'Forgot', children: [
                                  TextSpan(
                                    text: ' password?',
                                  )
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
