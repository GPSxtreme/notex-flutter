// ignore_for_file: constant_identifier_names

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/data/models/updatable_user_data_model.dart';
import 'package:notex/presentation/blocs/user/user_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'dart:io';
import '../../main.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';

//Image quality constant
///Defines the percent of quality of the original picked image.
const IMAGE_QUALITY = 100;
const IMAGE_HEIGHT = 550.0;
const IMAGE_WIDTH = 550.0;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserBloc userBloc = UserBloc();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late bool _saveChangesFlag;
  File? _imageFile;
  String _selectedCountry = USER.data!.country;

  @override
  void initState() {
    super.initState();
    initAction();
  }

  initAction() {
    _saveChangesFlag = false;
    userBloc.add(UserInitialEvent());
    _nameController.text = USER.data!.name;
    _dobController.text =
        DateFormat('MM/dd/yyyy').format(USER.data!.dob.toLocal());
    _emailController.text = USER.data!.email;
    _imageFile = null;
  }

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
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                ),
                title: const Text(
                  'Take a photo',
                ),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.image,
                ),
                title: const Text(
                  'Choose from gallery',
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
      bloc: userBloc,
      listenWhen: (previous, current) => current is UserActionState,
      buildWhen: (previous, current) => current is! UserActionState,
      listener: (context, state) {
        if (state is UserSendScaffoldMessageState) {
          kSnackBar(context, state.message);
        } else if (state is UserOperationFailedState) {
          kSnackBar(context, state.reason);
        } else if (state is UserResetAfterUpdateState) {
          initAction();
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is UserSettingsFetchedState) {
          if ((_nameController.text.isNotEmpty &&
                  _nameController.text.trim() != state.user.name) ||
              (_dobController.text.isNotEmpty &&
                  (DateFormat('MM/dd/yyyy').parse(_dobController.text))
                          .toUtc() !=
                      state.user.dob) ||
              (_selectedCountry.trim().isNotEmpty &&
                  _selectedCountry.trim() != state.user.country) ||
              _imageFile != null) {
            _saveChangesFlag = true;
          } else {
            _saveChangesFlag = false;
          }
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.secondary,
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md),
                  child: IconButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent)),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                );
              },
            ),
            title: const Text(
              "Profile",
            ),
            actions: [
              if (state is UserSettingsFetchedState)
                Padding(
                  padding: EdgeInsets.only(
                      right: SizeConfig.blockSizeHorizontal! * 5),
                  child: PopupMenuButton<String>(
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    icon: const Icon(
                      Ionicons.ellipsis_vertical,
                    ),
                    splashRadius: 20,
                    onSelected: (value) {
                      switch (value) {
                        case 'copyId':
                          Clipboard.setData(
                              ClipboardData(text: state.user.userId));
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'copyId',
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            horizontalTitleGap: 15,
                            leading: Icon(
                              Icons.copy_rounded,
                            ),
                            title: Text(
                              'user id',
                            ),
                            tileColor: Colors.transparent,
                          ),
                        ),
                      ];
                    },
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is UserFetchingState) ...[
                  const Center(
                    child: SpinKitRing(
                      color: AppColors.primary,
                      size: 35,
                    ),
                  )
                ] else if (state is UserSettingsFetchedState) ...[
                  Material(
                    color: Colors.transparent,
                    elevation: 20,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100)),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(100)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 15),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(100),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius:
                                          SizeConfig.blockSizeHorizontal! * 18,
                                      backgroundImage: (_imageFile != null)
                                          ? FileImage(_imageFile!)
                                          : state.profilePicture
                                              as ImageProvider,
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        borderRadius: AppBorderRadius.full,
                                        child: InkWell(
                                          borderRadius: AppBorderRadius.full,
                                          onTap: () {
                                            _showPickOptions();
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Material(
                                        elevation: 5.0,
                                        color: AppColors.muted,
                                        borderRadius: AppBorderRadius.full,
                                        child: InkWell(
                                          borderRadius: AppBorderRadius.full,
                                          onTap: _showPickOptions,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(AppSpacing.sm),
                                            child: Icon(
                                              Icons.edit,
                                              color: AppColors.primary,
                                              size: AppSpacing.iconSizeXl,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: AppSpacing.lg,
                              ),
                              Text(
                                state.user.name,
                                style: AppText.textLgSemiBold,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: AppSpacing.sm,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.user.isEmailVerified
                                        ? 'Verified'
                                        : 'Not verified',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    width: AppSpacing.sm,
                                  ),
                                  Material(
                                    color: state.user.isEmailVerified
                                        ? AppColors.primary
                                        : AppColors.destructive,
                                    borderRadius: BorderRadius.circular(100),
                                    child: Icon(
                                      state.user.isEmailVerified
                                          ? Icons.check
                                          : Icons.close,
                                      size: 12,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: AppSpacing.sm,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          readOnly: true,
                          enableInteractiveSelection: false,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller: _dobController,
                                keyboardType: TextInputType.datetime,
                              ),
                            ),
                            SizedBox(
                              width: AppSpacing.sm,
                            ),
                            IntrinsicHeight(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _selectDate();
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
                          borderRadius: AppBorderRadius.md,
                          child: InkWell(
                            borderRadius: AppBorderRadius.md,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: AppBorderRadius.md,
                              ),
                              child: CountryCodePicker(
                                padding: EdgeInsets.zero,
                                barrierColor: Colors.transparent,
                                backgroundColor: AppColors.background,
                                initialSelection: state.user.country,
                                boxDecoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: AppBorderRadius.md,
                                ),
                                searchDecoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors
                                      .transparent, // Background color for the text field
                                  hintStyle: AppText.textBase.copyWith(
                                      color: AppColors.mutedForeground),
                                  border: OutlineInputBorder(
                                    // Normal state border
                                    borderRadius: AppBorderRadius.lg,
                                    borderSide: const BorderSide(
                                        color:
                                            AppColors.border), // Border color
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    // Enabled state border
                                    borderRadius: AppBorderRadius.lg,

                                    borderSide: const BorderSide(
                                        color: AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    // Focused state border
                                    borderRadius: AppBorderRadius.lg,
                                    borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width:
                                            1.0), // Thicker border when focused
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
                        if (_saveChangesFlag)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: !state.isUpdating
                                    ? () {
                                        userBloc.add(UserUpdateUserDataEvent(
                                            img: _imageFile,
                                            data: UpdatableUserDataModel(
                                                dob: DateFormat('MM/dd/yyyy')
                                                    .parse(_dobController.text)
                                                    .toUtc(),
                                                name: _nameController.text,
                                                countryCode:
                                                    _selectedCountry)));
                                      }
                                    : null,
                                child: !state.isUpdating
                                    ? const Text(
                                        "Save",
                                      )
                                    : const SpinKitCircle(
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
