import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/register/register_bloc.dart';
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

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPinkD1;
    }
    return kPinkD1;
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
            backgroundColor: kPageBgStart,
            body: SafeArea(
              child: Container(
                height: SizeConfig.screenHeight,
                width: SizeConfig.screenWidth,
                decoration: const BoxDecoration(
                  gradient: kPageBgGradient,
                ),
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
                                    style: kAppFont.copyWith(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "account",
                                    style: kAppFont.copyWith(
                                        fontSize: 25,
                                        color: kPink,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 10,
                              ),
                              TextField(
                                style: kAppFont.copyWith(fontSize: 18),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: kWhite,
                                decoration: kTextFieldDecorationT1.copyWith(
                                    labelText: "Email"),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              TextField(
                                style: kAppFont.copyWith(fontSize: 18),
                                keyboardType: TextInputType.text,
                                controller: _passwordController,
                                cursorColor: kWhite,
                                obscureText: _hide,
                                decoration: kTextFieldDecorationT1.copyWith(
                                    labelText: "Password",
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _hide = !_hide;
                                          });
                                        },
                                        icon: Icon(
                                          _hide
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: kWhite,
                                        ))),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              TextField(
                                style: kAppFont.copyWith(fontSize: 18),
                                keyboardType: TextInputType.text,
                                controller: _confirmPasswordController,
                                cursorColor: kWhite,
                                obscureText: _hideConfirm,
                                decoration: kTextFieldDecorationT1.copyWith(
                                    labelText: "confirm password",
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _hideConfirm = !_hideConfirm;
                                          });
                                        },
                                        icon: Icon(
                                          _hideConfirm
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: kWhite,
                                        ))),
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
                                        checkColor: kPink,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                getColor),
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
                                      style: kAppFont.copyWith(
                                          fontSize: 16, color: kWhite24),
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
                                  style: kBtnStyleT1,
                                  child: state is! RegisterLoadingState
                                      ? Text(
                                          "Register",
                                          style: kAppFont.copyWith(fontSize: 20),
                                        )
                                      : const SpinKitCircle(
                                          color: kWhite,
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
                                    style: kAppFont.copyWith(fontSize: 16),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        // go to login page
                                        registerBloc.add(
                                            RegisterPageLoginButtonPressedEvent());
                                      },
                                      child: Text(
                                        "Login",
                                        style: kAppFont.copyWith(
                                            fontSize: 16, color: kPink),
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
