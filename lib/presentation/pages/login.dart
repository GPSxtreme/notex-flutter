import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/login/login_bloc.dart';
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
      bloc: loginBloc,
      listenWhen: (previous,current) => current is LoginActionState,
      buildWhen: (previous,current) => current is! LoginActionState,
      listener: (context,state){
        if(state is LoginNavigateToRegisterPageActionState){
          GoRouter.of(context).pushNamed(AppRouteConstants.registerRouteName);
        } else if(state is LoginSuccessState){
          GoRouter.of(context).pushReplacementNamed(AppRouteConstants.homeRouteName);
        } else if(state is LoginFailedState){
          kSnackBar(context, state.reason);
        }
      },
      builder: (context,state){
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: kPinkD2,
          body: SafeArea(
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              decoration: const BoxDecoration(gradient: kPageBgGradient),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: -SizeConfig.blockSizeHorizontal! * 0.5,
                    child: SvgPicture.asset('assets/svg/login_page_bg_decor.svg'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: SizeConfig.blockSizeVertical! * 20,),
                            Text(
                              "Sign in to",
                              style: kAppFont.copyWith(fontSize: 35),
                            ),
                            Row(
                              children: [
                                Text(
                                  "your ",
                                  style: kAppFont.copyWith(fontSize: 35),
                                ),
                                Text(
                                  "account",
                                  style: kAppFont.copyWith(fontSize: 35, color: kPink),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 15,
                            ),
                            TextField(
                              style: kAppFont.copyWith(fontSize: 18),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: kWhite,
                              decoration:
                              kTextFieldDecorationT1.copyWith(labelText: "Email"),
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
                                        _hide ? Icons.visibility : Icons.visibility_off,
                                        color: kWhite,
                                      ))),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                            ),
                            Row(
                              children: [
                                Transform.scale(
                                  scale:1.3,
                                  child: Checkbox(
                                      value: _rememberDevice,
                                      checkColor: kPink,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      fillColor:
                                      MaterialStateProperty.resolveWith(getColor),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _rememberDevice = value!;
                                        });
                                      }),
                                ),
                                GestureDetector(
                                  onTap: (){
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
                                onPressed: state is! LoginLoadingSate ? () {
                                  // login user
                                  if (_emailController.text.isEmpty ||
                                      _passwordController.text.isEmpty) {
                                    kSnackBar(context, 'Please fill in all fields');
                                  } else {
                                    loginBloc.add(LoginPageLoginButtonClickedEvent(_emailController.text, _passwordController.text,_rememberDevice));
                                  }
                                } : null,
                                style: kBtnStyleT1,
                                child: state is! LoginLoadingSate ? Text(
                                  "Login",
                                  style: kAppFont.copyWith(fontSize: 20),
                                ) :const SpinKitCircle(color: kWhite,size: 22,),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: kAppFont.copyWith(fontSize: 16),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // go to register page
                                      loginBloc.add(LoginPageRegisterButtonClickedEvent());
                                    },
                                    child: Text(
                                      "Register ",
                                      style: kAppFont.copyWith(fontSize: 16, color: kPink),
                                    )),
                              ],
                            )
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
