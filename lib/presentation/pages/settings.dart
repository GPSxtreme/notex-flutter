import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/core/repositories/shared_preferences_repository.dart';
import 'package:notex/presentation/styles/app_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoSync;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    getSettings();
  }

  getSettings()async{
    setState(() {
      _isLoading = true;
    });
    _autoSync = await SharedPreferencesRepository.getAutoSyncStatus() ?? false;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.arrow_back),
              onPressed: () { GoRouter.of(context).pop(); },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
        title: Text("Settings",style: kInter,),
        backgroundColor: kPageBgStart,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPageBgGradient
        ),
        child: !_isLoading ? ListTileTheme(
          textColor: kWhite,
          iconColor: kPinkD1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync,color: kPinkD1,size: 30,),
                title: Text('Enable auto-sync',style: kInter.copyWith(fontSize: 15),),
                subtitle: Text('This enables auto-sync for both notes and todos.',style: kInter.copyWith(color: kWhite75,fontSize: 12),),
                trailing: Switch(
                  activeColor: kPink,
                  activeTrackColor: kPinkD1,
                  inactiveThumbColor: kPinkD1,
                  inactiveTrackColor: kPinkD2,
                  value: _autoSync,
                  onChanged: (value)async{
                    setState(() {
                      _autoSync = value;
                    });
                    await SharedPreferencesRepository.setAutoSyncStatus(value);
                  },
                ),
              )
            ],
          ),
        ) : const Center(
          child: SpinKitRing(
            lineWidth: 3.0,
            color: kPinkD1,
          ),
        ),
      ),
    );
  }
}
