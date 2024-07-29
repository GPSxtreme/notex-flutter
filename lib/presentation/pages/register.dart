import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/register/register_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/widgets/fit_width_box.dart';
import 'package:notex/router/app_route_constants.dart';

import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterBloc registerBloc = RegisterBloc();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _hide = true;
  bool _hideConfirm = true;
  bool _rememberDevice = false;

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
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // register user
      registerBloc.add(RegisterPageRegisterButtonPressedEvent(
          _emailController.text, _passwordController.text, _rememberDevice));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
        bloc: registerBloc,
        listenWhen: (previous, current) => current is RegisterActionState,
        buildWhen: (previous, current) => current is! RegisterActionState,
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            // go to create user profile screen
            context.goNamed(AppRouteConstants.createUserProfileName);
          } else if (state is RegisterFailedState) {
            kSnackBar(context, state.reason);
          } else if (state is RegisterRedirectToLoginState) {
            GoRouter.of(context).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: FitWidthBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: SizeConfig.blockSizeVertical! * 7,
                      ),
                      Center(
                          child: SvgPicture.asset(
                        "assets/svg/app_logo_v2.svg",
                        width: SizeConfig.blockSizeHorizontal! * 40,
                      )),
                      SizedBox(
                        height: AppSpacing.xxxl,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Register ",
                            style: AppText.text2XlMedium,
                          ),
                          Text(
                            "account",
                            style: AppText.text2XlMedium
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
                            SizedBox(
                              height: AppSpacing.md,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              validator: _confirmPasswordValidator,
                              decoration: InputDecoration(
                                  hintText: 'Confirm password',
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
                                            _hideConfirm = !_hideConfirm;
                                          });
                                        },
                                        child: Icon(
                                          _hideConfirm
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.foreground,
                                          size: AppSpacing.iconSizeLg,
                                        ),
                                      ))),
                              controller: _confirmPasswordController,
                              obscureText: _hideConfirm,
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
                              state is! RegisterLoadingState ? _register : null,
                          child: state is! RegisterLoadingState
                              ? Text(
                                  "Register",
                                  style: AppText.textLgBold,
                                )
                              : SpinKitCircle(
                                  color: AppColors.primary,
                                  size: AppSpacing.iconSize2Xl,
                                ),
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.xxxl,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Have an account? ",
                            style: AppText.textBase,
                          ),
                          GestureDetector(
                              onTap: () {
                                // go to login page
                                registerBloc
                                    .add(RegisterPageLoginButtonPressedEvent());
                              },
                              child: Text(
                                "Login",
                                style: AppText.textBaseSemiBold
                                    .copyWith(color: AppColors.primary),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: AppSpacing.xxxl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
