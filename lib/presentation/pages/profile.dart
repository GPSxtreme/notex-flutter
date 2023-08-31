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
  initAction(){
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
        backgroundColor: kPinkD2,
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
      bloc: userBloc,
      listenWhen: (previous, current) => current is UserActionState,
      buildWhen: (previous, current) => current is! UserActionState,
      listener: (context, state) {
        if (state is UserSendScaffoldMessageState) {
          kSnackBar(context, state.message);
        } else if (state is UserOperationFailedState) {
          kSnackBar(context, state.reason);
        } else if(state is UserResetAfterUpdateState){
          initAction();
          setState(() {
          });
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
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                );
              },
            ),
            title: Text(
              "Profile",
              style: kAppFont.copyWith(fontWeight: FontWeight.w600, fontSize: 19),
            ),
            backgroundColor: kPinkD1,
            actions: [
              if(state is UserSettingsFetchedState)
              Padding(
                padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal! * 5),
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: kPinkD2,
                  icon: const Icon(
                    Ionicons.ellipsis_vertical,
                    color: kWhite,
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
                      PopupMenuItem<String>(
                        value: 'copyId',
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 0),
                          horizontalTitleGap: 15,
                          leading: const Icon(
                            Icons.copy_outlined,
                            color: kPinkD1,
                          ),
                          title: Text(
                            'user id',
                            style: kAppFont.copyWith(fontSize: 13),
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
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: const BoxDecoration(gradient: kPageBgGradient),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state is UserFetchingState) ...[
                    const Center(
                      child: SpinKitRing(
                        color: kWhite,
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
                          color: kPink,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 30, bottom: 15),
                          decoration: const BoxDecoration(
                            color: kPinkD1,
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
                                            SizeConfig.blockSizeHorizontal! *
                                                18,
                                        backgroundColor: kPinkD1,
                                        backgroundImage: (_imageFile != null)
                                            ? FileImage(_imageFile!)
                                            : state.profilePicture
                                                as ImageProvider,
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(999),
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
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(999),
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
                                  height: SizeConfig.blockSizeVertical! * 2,
                                ),
                                Text(
                                  state.user.name,
                                  style: kAppFont.copyWith(
                                      color: kWhite,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical!,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      state.user.isEmailVerified
                                          ? 'Verified'
                                          : 'Not verified',
                                      style: kAppFont.copyWith(
                                          color: kWhite24,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Material(
                                      color: state.user.isEmailVerified
                                          ? kPink
                                          : kRed,
                                      borderRadius: BorderRadius.circular(100),
                                      child: Icon(
                                        state.user.isEmailVerified
                                            ? Icons.check
                                            : Icons.close,
                                        color: kWhite,
                                        size: 12,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 8,
                          ),
                          TextField(
                            style: kAppFont.copyWith(fontSize: 18),
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            cursorColor: kWhite,
                            decoration: kTextFieldDecorationT1.copyWith(
                                labelText: "Email"),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 2,
                          ),
                          TextField(
                            style: kAppFont.copyWith(fontSize: 18),
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            cursorColor: kWhite,
                            decoration: kTextFieldDecorationT1.copyWith(
                                labelText: "Username"),
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
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              ElevatedButton(
                                style: kBtnStyleT2,
                                onPressed: () async {
                                  await _selectDate();
                                },
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: kPink,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 5,
                          ),
                          Text(
                            " country",
                            style: kAppFont.copyWith(color: kWhite24),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeHorizontal! * 2,
                          ),
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
                                    color:
                                        kPinkD1, // Change the border color here
                                  ),
                                ),
                                child: CountryCodePicker(
                                  padding: EdgeInsets.zero,
                                  initialSelection: state.user.country,
                                  emptySearchBuilder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "Please enter your country code / telephone code if no results are shown.",
                                        style: kAppFont.copyWith(fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                  showOnlyCountryWhenClosed: true,
                                  showCountryOnly: true,
                                  dialogSize: Size(
                                      SizeConfig.screenWidth! * 0.8,
                                      SizeConfig.screenHeight! * 0.8),
                                  searchStyle: kAppFont,
                                  barrierColor: kPinkD2,
                                  flagWidth:
                                      SizeConfig.blockSizeHorizontal! * 10,
                                  alignLeft: true,
                                  dialogTextStyle: kAppFont,
                                  // dialogBackgroundColor: kPinkD1.withOpacity(0.7),
                                  searchDecoration: kTextFieldDecorationT1,
                                  showDropDownButton: true,
                                  textStyle: kAppFont,
                                  closeIcon: const Icon(
                                    Icons.close,
                                    color: kWhite,
                                    size: 25,
                                  ),
                                  backgroundColor: kPinkD2,
                                  dialogBackgroundColor:
                                      kPinkD1.withOpacity(0.3),
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
                                  onPressed: !state.isUpdating ? () {
                                    userBloc.add(UserUpdateUserDataEvent(img: _imageFile,
                                        data: UpdatableUserDataModel(
                                            dob: DateFormat('MM/dd/yyyy')
                                                .parse(_dobController.text).toUtc(),
                                            name: _nameController.text,
                                            countryCode: _selectedCountry)));
                                  } : null,
                                  style: kBtnStyleT1,
                                  child: !state.isUpdating ? Text(
                                    "Save",
                                    style: kAppFont.copyWith(fontSize: 20),
                                  ) : const SpinKitCircle(color: kWhite,size: 20,),
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
          ),
        );
      },
    );
  }
}
