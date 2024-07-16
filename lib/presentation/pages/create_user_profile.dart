// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/blocs/create_user_profile/create_user_profile_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
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
  String _selectedCountry = 'IN';
  File? _imageFile;

  Future<void> _selectDate() async {
    final DateTime currentDate = DateTime.now();
    final DateTime tenYearsAgo =
        currentDate.subtract(const Duration(days: 365 * 10));
    final DateTime hundredYearsAgo =
        currentDate.subtract(const Duration(days: 365 * 100));
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
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPickOptions() => showModalBottomSheet(
        showDragHandle: true,
        context: context,
        backgroundColor: AppColors.secondary,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.mutedForeground,
                  ),
                  title: Text(
                    'Take a photo',
                    style: AppText.textBaseSemiBold,
                  ),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.image_rounded,
                    color: AppColors.mutedForeground,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: AppText.textBaseSemiBold,
                  ),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: createUserProfileBloc,
      buildWhen: (previous, current) =>
          current is! CreateUserProfileActionState,
      listenWhen: (previous, current) =>
          current is CreateUserProfileActionState,
      listener: (context, state) {
        if (state is CreateUserProfileOpenDatePickerState) {
          _selectDate();
        } else if (state is CreateUserProfileFailedState) {
          kSnackBar(context, state.reason);
        } else if (state is CreateUserProfileSuccessState) {
          GoRouter.of(context)
              .pushReplacementNamed(AppRouteConstants.homeRouteName);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical!,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Setup ",
                        style: AppText.text2XlBold,
                      ),
                      Text(
                        "profile",
                        style: AppText.text2XlBold
                            .copyWith(color: AppColors.primary),
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
                          backgroundColor: AppColors.secondary,
                          backgroundImage: (_imageFile != null)
                              ? FileImage(_imageFile!)
                              : null,
                          child: Material(
                            color: Colors.transparent,
                            elevation: 0,
                            borderRadius: AppBorderRadius.full,
                            child: InkWell(
                              borderRadius: AppBorderRadius.full,
                              onTap: () {
                                _showPickOptions();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (_imageFile == null) ...[
                                        Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  17,
                                        ),
                                        Text(
                                          "Add picture",
                                          style: AppText.textSmBold.copyWith(
                                              color: AppColors.primary),
                                        )
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
                            borderRadius: AppBorderRadius.full,
                            child: InkWell(
                              borderRadius: AppBorderRadius.full,
                              onTap: _showPickOptions,
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary),
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.secondary,
                                    size: AppSpacing.iconSizeLg,
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
                      controller: _nameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: "Name",
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppColors.mutedForeground,
                          ))),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical! * 2,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: () {
                            createUserProfileBloc
                                .add(CreateUserProfileOpenDatePickerEvent());
                          },
                          decoration: const InputDecoration(
                              hintText: "MM/dd/yyyy",
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: AppColors.mutedForeground,
                              )),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(
                        width: AppSpacing.sm,
                      ),
                      IntrinsicHeight(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.lg,
                            ),
                          ),
                          onPressed: () {
                            createUserProfileBloc
                                .add(CreateUserProfileOpenDatePickerEvent());
                          },
                          child: const Icon(
                            Icons.calendar_month,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: AppSpacing.lg,
                  ),
                  Text(" Country",
                      style: AppText.textSm.copyWith(
                        color: AppColors.mutedForeground,
                      )),
                  SizedBox(
                    height: AppSpacing.md,
                  ),
                  Material(
                    borderRadius: AppBorderRadius.lg,
                    child: InkWell(
                      borderRadius: AppBorderRadius.lg,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppBorderRadius.lg,
                        ),
                        child: CountryCodePicker(
                          padding: EdgeInsets.zero,
                          barrierColor: Colors.transparent,
                          backgroundColor: AppColors.background,
                          initialSelection: _selectedCountry,
                          boxDecoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: AppBorderRadius.lg,
                              border: Border.all(
                                  color: AppColors.border, width: 1.0)),
                          searchDecoration: InputDecoration(
                            filled: true,
                            fillColor: Colors
                                .transparent, // Background color for the text field
                            hintStyle: AppText.textBase
                                .copyWith(color: AppColors.mutedForeground),
                            border: OutlineInputBorder(
                              // Normal state border
                              borderRadius: AppBorderRadius.lg,
                              borderSide: const BorderSide(
                                  color: AppColors.border), // Border color
                            ),
                            enabledBorder: OutlineInputBorder(
                              // Enabled state border
                              borderRadius: AppBorderRadius.lg,

                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              // Focused state border
                              borderRadius: AppBorderRadius.lg,
                              borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.0), // Thicker border when focused
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical:
                                    12.0), // Padding inside the text field
                          ),
                          emptySearchBuilder: (context) {
                            return Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Text(
                                  "Please enter your country code / telephone code if no results are shown.",
                                  textAlign: TextAlign.center,
                                  style: AppText.textSm.copyWith(
                                    color: AppColors.mutedForeground,
                                  )),
                            );
                          },
                          showOnlyCountryWhenClosed: true,
                          showCountryOnly: true,
                          dialogSize: Size(SizeConfig.screenWidth! * 0.8,
                              SizeConfig.screenHeight! * 0.8),
                          flagWidth: SizeConfig.blockSizeHorizontal! * 10,
                          alignLeft: true,
                          showDropDownButton: true,
                          closeIcon: const Icon(
                            Icons.close,
                            size: 25,
                          ),
                          onChanged: (CountryCode countryCode) {
                            setState(() {
                              _selectedCountry = countryCode.code!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 20,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: state is! CreateUserProfileLoadingState
                          ? () {
                              if (_imageFile == null ||
                                  _nameController.text.isEmpty ||
                                  _dobController.text.isEmpty ||
                                  _selectedCountry.isEmpty) {
                                if (_imageFile == null) {
                                  kSnackBar(
                                      context, "Please add a profile picture");
                                } else {
                                  kSnackBar(
                                      context, "Please fill in all fields");
                                }
                              } else {
                                // create user profile
                                createUserProfileBloc.add(
                                    CreateUserProfileCreateEvent(
                                        UpdatableUserDataModel(
                                            countryCode: _selectedCountry,
                                            dob: DateFormat('MM/dd/yyyy')
                                                .parse(_dobController.text)
                                                .toUtc(),
                                            name: _nameController.text),
                                        _imageFile!));
                              }
                            }
                          : null,
                      child: state is! CreateUserProfileLoadingState
                          ? Text(
                              "Save",
                              style: AppText.textBaseBold,
                            )
                          : const SpinKitCircle(
                              color: AppColors.primary,
                              size: 20,
                            ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
