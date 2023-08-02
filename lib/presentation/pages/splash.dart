import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/animations/fade_in_animation.dart';
import 'package:notex/presentation/blocs/splash/splash_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/router/app_route_constants.dart';

import '../styles/size_config.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>{
  final SplashBloc splashBloc = SplashBloc();
  @override
  void initState() {
    splashBloc.add(SplashInitialEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocConsumer<SplashBloc,SplashState>(
      bloc: splashBloc,
      listenWhen: (previous,current) => current is SplashActionState,
      buildWhen: (previous,current) => current is! SplashActionState,
      listener: (context,state){
        if(state is SplashUserNotAuthenticatedState){
          GoRouter.of(context).goNamed(AppRouteConstants.loginRouteName);
        } else if (state is  SplashUserAuthenticatedState){
          // GoRouter.of(context).go("/${AppRouteConstants.notesRouteName}");
          GoRouter.of(context).goNamed(AppRouteConstants.homeRouteName);

        }

      },
      builder: (context, state){
        return Scaffold(
          body: Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            decoration: const BoxDecoration(
                gradient: kPageBgGradient
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: FadeInAnimation(child: SvgPicture.asset('assets/svg/app_logo.svg')))
                  ],
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if(state is SplashLoadingState) ...[
                        const SpinKitRing(color: kPinkD1,size: 30,),
                        SizedBox(height: SizeConfig.blockSizeVertical,),
                      ],
                      Center(child: kDevLogo,),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
