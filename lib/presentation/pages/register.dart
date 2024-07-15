import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/register/register_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
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
  bool _hide = true;
  bool _hideConfirm = true;
  bool _rememberDevice = false;

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
          } else if (state is RegisterEmptyCredentialsState) {
            kSnackBar(context, "Please fill in all fields");
          } else if (state is RegisterPasswordsDoNotMatchState) {
            kSnackBar(context, "Passwords do not match");
            _confirmPasswordController.clear();
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Container(
                height: SizeConfig.screenHeight,
                width: SizeConfig.screenWidth,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: SvgPicture.asset(
                        "assets/svg/register_background_decoration.svg",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overScroll) {
                          overScroll.disallowIndicator();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                height: SizeConfig.blockSizeVertical! * 7,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Register ",
                                  ),
                                  Text(
                                    "account",
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 10,
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
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              TextField(
                                keyboardType: TextInputType.text,
                                controller: _confirmPasswordController,
                                obscureText: _hideConfirm,
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 2,
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
                                  onPressed: state is! RegisterLoadingState
                                      ? () {
                                          if (_emailController.text.isEmpty ||
                                              _passwordController
                                                  .text.isEmpty ||
                                              _confirmPasswordController
                                                  .text.isEmpty) {
                                            registerBloc.add(
                                                RegisterPageEmptyCredentialsEvent());
                                          } else if (_passwordController.text !=
                                              _confirmPasswordController.text) {
                                            registerBloc.add(
                                                RegisterPagePasswordsDoNotMatchEvent());
                                          } else {
                                            // register user
                                            registerBloc.add(
                                                RegisterPageRegisterButtonPressedEvent(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                    _rememberDevice));
                                          }
                                        }
                                      : null,
                                  child: state is! RegisterLoadingState
                                      ? Text(
                                          "Register",
                                        )
                                      : SpinKitCircle(
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Have an account? ",
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        // go to login page
                                        registerBloc.add(
                                            RegisterPageLoginButtonPressedEvent());
                                      },
                                      child: Text(
                                        "Login",
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
