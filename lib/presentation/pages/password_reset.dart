// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notex/core/repositories/auth_repository.dart';

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
      backgroundColor: kPageBgStart,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.blockSizeVertical! * 20,),
                    Text(
                      "Reset your",
                      style: kAppFont.copyWith(fontSize: 35),
                    ),
                    Row(
                      children: [
                        Text(
                          "Account ",
                          style: kAppFont.copyWith(fontSize: 35),
                        ),
                        Text(
                          "password",
                          style: kAppFont.copyWith(fontSize: 35, color: kPink),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 5,
                    ),
                    Text(
                      "We know managing passwords is a hassle!\nPlease provide your account email so that we can send a password reset link.",
                      style: kAppFont.copyWith(fontSize: 16),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 5,
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
                              style: kAppFont.copyWith(fontSize: 17,fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(
                                  text: 'sent',
                                  style: kAppFont.copyWith(fontSize: 17,fontWeight: FontWeight.w700,color: kPink),
                                ),
                                TextSpan(
                                  text: '\nCheck spam if not found',
                                  style: kAppFont.copyWith(fontSize: 15),
                                )
                              ]
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed:!_isLoading ? ()async{
                              setState(() {
                                _isLoading = true;
                              });
                              if(_emailController.text.isNotEmpty){
                                final response = await AuthRepository.sendPasswordResetLink(email: _emailController.text);
                                if(response.success){
                                  _isSent = true;
                                }else{
                                  kSnackBar(context,response.message);
                                }
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            } : null,
                            style: kBtnStyleT1,
                            child: !_isLoading ? Text(
                              "Send Link",
                              style: kAppFont.copyWith(fontSize: 20),
                            ) :const SpinKitCircle(color: kWhite,size: 22,),
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
