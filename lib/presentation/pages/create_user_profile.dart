// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/create_user_profile/create_user_profile_bloc.dart';
import 'package:notex/presentation/styles/size_config.dart';
import 'package:notex/router/app_route_constants.dart';
import '../../data/models/updatable_user_data_model.dart';
import '../styles/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

//Image quality constant
///Defines the percent of quality of the original picked image.
const IMAGE_QUALITY = 100;
const IMAGE_HEIGHT = 550.0;
const IMAGE_WIDTH = 550.0;

class CreateUserProfile extends StatefulWidget {
  const CreateUserProfile({super.key});

  @override
  State<CreateUserProfile> createState() => _CreateUserProfileState();
}

class _CreateUserProfileState extends State<CreateUserProfile> {
  final CreateUserProfileBloc createUserProfileBloc = CreateUserProfileBloc();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _selectedCountry = 'India';
  File? _imageFile;


  Future<void> _selectDate() async {
    final DateTime currentDate = DateTime.now();
    final DateTime tenYearsAgo = currentDate.subtract(const Duration(days: 365 * 10));
    final DateTime hundredYearsAgo = currentDate.subtract(const Duration(days: 365 * 100));
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: tenYearsAgo,
        firstDate: hundredYearsAgo,
        lastDate: tenYearsAgo);
    if (picked != null) {
      String formattedDate = DateFormat('MM/dd/yyyy').format(picked);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: IMAGE_QUALITY,
        maxHeight: IMAGE_HEIGHT,
        maxWidth: IMAGE_WIDTH);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  void _showPickOptions() => showModalBottomSheet(
    backgroundColor: kPinkD2,
    showDragHandle: true,
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.camera_alt,
              color: kWhite,
            ),
            title: Text(
              'Take a photo',
              style: kAppFont,
            ),
            onTap: () {
              _pickImage(ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.image,
              color: kWhite,
            ),
            title: Text(
              'Choose from gallery',
              style: kAppFont,
            ),
            onTap: () {
              _pickImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: createUserProfileBloc,
      buildWhen: (previous,current) => current is! CreateUserProfileActionState,
      listenWhen: (previous,current) => current is CreateUserProfileActionState,
      listener: (context, state) {
        if(state is CreateUserProfileOpenDatePickerState){
          _selectDate();
        } else if(state is CreateUserProfileFailedState){
          kSnackBar(context, state.reason);
        } else if(state is CreateUserProfileSuccessState){
          GoRouter.of(context).pushReplacementNamed(AppRouteConstants.homeRouteName);
        }
      },
      builder: (context, state) {
        return Scaffold(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Setup ",
                                      style: kAppFont.copyWith(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      "profile",
                                      style: kAppFont.copyWith(
                                          fontSize: 30,
                                          color: kPink,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 8,
                                ),
                                Center(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: SizeConfig.blockSizeHorizontal! * 18,
                                        backgroundColor: kPinkD1,
                                        backgroundImage: (_imageFile != null)
                                            ? FileImage(_imageFile!) : null,
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          borderRadius: BorderRadius.circular(999),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(999),
                                            onTap: () {
                                              _showPickOptions();
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child:  Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (_imageFile == null) ...[
                                                      Icon(Icons.person, color: kPink, size: SizeConfig.blockSizeHorizontal! * 17,),
                                                      Text("Add picture", style: kAppFont.copyWith(fontSize: 11),)
                                                    ]
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Material(
                                          elevation: 5.0,
                                          borderRadius: BorderRadius.circular(999),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(999),
                                            onTap: _showPickOptions,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: kPink,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: kPinkD1,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 10,
                                ),
                                TextField(
                                  style: kAppFont.copyWith(fontSize: 18),
                                  controller: _nameController,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: kWhite,
                                  decoration: kTextFieldDecorationT1.copyWith(
                                      labelText: "Name"),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 2,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        style: kAppFont.copyWith(fontSize: 18),
                                        controller: _dobController,
                                        keyboardType: TextInputType.datetime,
                                        cursorColor: kWhite,
                                        decoration: kTextFieldDecorationT1.copyWith(
                                            labelText: "Date of birth"),
                                      ),
                                    ),
                                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),
                                    ElevatedButton(
                                      style: kBtnStyleT2,
                                      onPressed: (){
                                        createUserProfileBloc.add(CreateUserProfileOpenDatePickerEvent());
                                      },
                                      child: const Icon(Icons.calendar_month,color: kPink,),
                                    )
                                  ],
                                ),
                                SizedBox(height: SizeConfig.blockSizeHorizontal! * 5,),
                                Text(" country",style: kAppFont.copyWith(color: kWhite24),),
                                SizedBox(height: SizeConfig.blockSizeHorizontal! * 2,),
                                Material(
                                  color: kWhite.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(15),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    splashColor: kPinkD1.withOpacity(0.03),
                                    radius: 15,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          width: 2.0,
                                          color: kPinkD1, // Change the border color here
                                        ),
                                      ),
                                      child: CountryCodePicker(
                                        padding: EdgeInsets.zero,
                                        initialSelection: 'IN',
                                        emptySearchBuilder: (context){
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text("Please enter your country code / telephone code if no results are shown.",style: kAppFont.copyWith(fontSize: 13),textAlign: TextAlign.center,),
                                          );
                                        },
                                        showOnlyCountryWhenClosed: true,
                                        showCountryOnly: true,
                                        dialogSize: Size(SizeConfig.screenWidth! * 0.8, SizeConfig.screenHeight! * 0.8),
                                        searchStyle: kAppFont,
                                        barrierColor: kPinkD2,
                                        flagWidth: SizeConfig.blockSizeHorizontal! * 10,
                                        alignLeft: true,
                                        dialogTextStyle: kAppFont,
                                        // dialogBackgroundColor: kPinkD1.withOpacity(0.7),
                                        searchDecoration: kTextFieldDecorationT1,
                                        showDropDownButton: true,
                                        textStyle: kAppFont,
                                        closeIcon: const Icon(Icons.close,color: kWhite,size: 25,),
                                        backgroundColor: kPinkD2,
                                        dialogBackgroundColor: kPinkD1.withOpacity(0.3),
                                        onChanged: (CountryCode countryCode) {
                                          setState(() {
                                            _selectedCountry = countryCode.code!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: SizeConfig.blockSizeHorizontal! * 20,),
                                SizedBox(
                                  width: double.maxFinite,
                                  child: ElevatedButton(
                                    onPressed: state is! CreateUserProfileLoadingState ? (){
                                      if(_imageFile == null || _nameController.text.isEmpty || _dobController.text.isEmpty || _selectedCountry.isEmpty){
                                        kSnackBar(context, "Please fill in all fields");
                                      }else{
                                        // create user profile
                                       createUserProfileBloc.add(CreateUserProfileCreateEvent(UpdatableUserDataModel(countryCode: _selectedCountry,dob:DateFormat('MM/dd/yyyy')
                                           .parse(_dobController.text).toUtc(),name: _nameController.text),_imageFile!));
                                      }
                                    } : null,
                                    style: kBtnStyleT1,
                                    child: state is! CreateUserProfileLoadingState ? Text(
                                      "Continue",
                                      style: kAppFont.copyWith(fontSize: 20),
                                    ) :const SpinKitCircle(color: kWhite,size: 22,),
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
