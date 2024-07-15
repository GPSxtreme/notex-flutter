// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/presentation/styles/app_colors.dart';

import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: -SizeConfig.blockSizeHorizontal! * 0.5,
                child: SvgPicture.asset('assets/svg/login_page_bg_decor.svg'),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 20,
                    ),
                    Text(
                      "Reset your",
                    ),
                    Row(
                      children: [
                        Text(
                          "Account ",
                        ),
                        Text(
                          "password",
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 5,
                    ),
                    Text(
                      "We know managing passwords is a hassle!\nPlease provide your account email so that we can send a password reset link.",
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 5,
                    ),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 3,
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 5,
                    ),
                    const Spacer(),
                    Visibility(
                      visible: !_isSent,
                      replacement: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: 'Password reset link ',
                                children: [
                                  TextSpan(
                                    text: 'sent',
                                  ),
                                  TextSpan(
                                    text: '\nCheck spam if not found',
                                  )
                                ]),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: !_isLoading
                                ? () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    if (_emailController.text.isNotEmpty) {
                                      final response = await AuthRepository
                                          .sendPasswordResetLink(
                                              email: _emailController.text);
                                      if (response.success) {
                                        _isSent = true;
                                      } else {
                                        kSnackBar(context, response.message);
                                      }
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                : null,
                            child: !_isLoading
                                ? Text(
                                    "Send Link",
                                  )
                                : SpinKitCircle(
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
