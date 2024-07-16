// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notex/core/repositories/auth_repository.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _mailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _onSendLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      if (_emailController.text.isNotEmpty) {
        final response = await AuthRepository.sendPasswordResetLink(
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
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -SizeConfig.blockSizeHorizontal! * 0.5,
              child: SvgPicture.asset('assets/svg/login_page_bg_decor.svg'),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 20,
                  ),
                  Text(
                    "Reset your",
                    style: AppText.text3XlBold,
                  ),
                  Row(
                    children: [
                      Text(
                        "Account ",
                        style: AppText.text3XlBold,
                      ),
                      Text(
                        "password",
                        style: AppText.text3XlBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 5,
                  ),
                  Text(
                    "We know managing passwords is a hassle!\nPlease provide your account email so that we can send a password reset link.",
                    style: AppText.textBase,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 5,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                        controller: _emailController,
                        validator: _mailValidator,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(
                            Icons.email,
                            color: AppColors.mutedForeground,
                          ),
                        )),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 8,
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
                              style: AppText.textXlSemiBold,
                              children: [
                                TextSpan(
                                  text: 'sent',
                                  style: AppText.textXlSemiBold
                                      .copyWith(color: AppColors.primary),
                                ),
                                TextSpan(
                                    text: '\nCheck spam if not found',
                                    style: AppText.textBaseSemiBold.copyWith(
                                        color: AppColors.mutedForeground))
                              ]),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: !_isLoading ? _onSendLink : null,
                          child: !_isLoading
                              ? Text(
                                  "Send Link",
                                  style: AppText.textLgBold,
                                )
                              : SpinKitCircle(
                                  color: AppColors.primary,
                                  size: AppSpacing.iconSize2Xl,
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
    );
  }
}
