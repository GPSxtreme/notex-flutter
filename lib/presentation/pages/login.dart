import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/login/login_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/widgets/fit_width_box.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final LoginBloc loginBloc = LoginBloc();
  bool _hide = true;
  bool _rememberDevice = false;

  @override
  void initState() {
    super.initState();
  }

  String? _mailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  // login method
  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      loginBloc.add(LoginPageLoginButtonClickedEvent(
          _emailController.text, _passwordController.text, _rememberDevice));
    }
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
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: SizedBox(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: -SizeConfig.blockSizeHorizontal! * 0.5,
                    child:
                        SvgPicture.asset('assets/svg/login_page_bg_decor.svg'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: FitWidthBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Sign in to",
                            style: AppText.text3XlBold,
                          ),
                          SizedBox(
                            height: AppSpacing.sm,
                          ),
                          Row(
                            children: [
                              Text(
                                "Your ",
                                style: AppText.text3XlBold,
                              ),
                              Text(
                                "Account",
                                style: AppText.text3XlBold
                                    .copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppSpacing.xxxl,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _mailValidator,
                                  decoration: InputDecoration(
                                      hintText: 'Email',
                                      prefixIcon: Icon(Icons.email,
                                          color: AppColors.mutedForeground,
                                          size: AppSpacing.iconSizeLg)),
                                ),
                                SizedBox(
                                  height: AppSpacing.md,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  validator: _passwordValidator,
                                  decoration: InputDecoration(
                                      hintText: 'Password',
                                      prefixIcon: Icon(Icons.password,
                                          color: AppColors.mutedForeground,
                                          size: AppSpacing.iconSizeLg),
                                      suffixIcon: Material(
                                          shape: const CircleBorder(),
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: AppBorderRadius.full,
                                            onTap: () {
                                              setState(() {
                                                _hide = !_hide;
                                              });
                                            },
                                            child: Icon(
                                              _hide
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: AppColors.foreground,
                                              size: AppSpacing.iconSizeLg,
                                            ),
                                          ))),
                                  controller: _passwordController,
                                  obscureText: _hide,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.lg,
                          ),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: _rememberDevice,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
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
                                child: Text("Remember device",
                                    style: AppText.textBase),
                              )
                            ],
                          ),
                          SizedBox(
                            height: AppSpacing.xxxl,
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              onPressed:
                                  state is! LoginLoadingSate ? _login : null,
                              child: state is! LoginLoadingSate
                                  ? Text(
                                      "Login",
                                      style: AppText.textLgBold,
                                    )
                                  : SpinKitCircle(
                                      color: AppColors.primary,
                                      size: AppSpacing.iconSize2Xl,
                                    ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                loginBloc.add(
                                    LoginPageForgotPasswordButtonClickedEvent());
                              },
                              child: const Text("Forgot password?"),
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.xxxl,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppText.textBase,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    // go to register page
                                    loginBloc.add(
                                        LoginPageRegisterButtonClickedEvent());
                                  },
                                  child: Text(
                                    "Register ",
                                    style: AppText.textBaseSemiBold
                                        .copyWith(color: AppColors.primary),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: AppSpacing.xl,
                          ),
                        ],
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
