import 'package:flutter/material.dart';
import 'package:phoenix/widgets/label_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/services/display_settings_controller.dart';


class DisplayPage extends StatefulWidget{
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{
  // initial value akan di-override di initState dari controller
  bool startSunday = true;
  bool addFromTop = false;
  bool show24Hour = false;
  bool showSmallPhoto = false;
  bool showSmallMemo = false;
  bool theme = false;

  @override
  void initState() {
    super.initState();
    // ambil nilai awal dari controller (ValueNotifier.value)
    startSunday = DisplaySettingsController.startSunday.value;
    addFromTop = DisplaySettingsController.addFromTop.value;
    show24Hour = DisplaySettingsController.show24Hour.value;
    showSmallPhoto = DisplaySettingsController.showSmallPhoto.value;
    showSmallMemo = DisplaySettingsController.showSmallMemo.value;
    theme = DisplaySettingsController.theme.value;

    // Optional: listen perubahan kalau value diubah dari tempat lain
    DisplaySettingsController.startSunday.addListener(() {
      setState(() => startSunday = DisplaySettingsController.startSunday.value);
    });
    DisplaySettingsController.addFromTop.addListener(() {
      setState(() => addFromTop = DisplaySettingsController.addFromTop.value);
    });
    DisplaySettingsController.show24Hour.addListener(() {
      setState(() => show24Hour = DisplaySettingsController.show24Hour.value);
    });
    DisplaySettingsController.showSmallPhoto.addListener(() {
      setState(() => showSmallPhoto = DisplaySettingsController.showSmallPhoto.value);
    });
    DisplaySettingsController.showSmallMemo.addListener(() {
      setState(() => showSmallMemo = DisplaySettingsController.showSmallMemo.value);
    });
    DisplaySettingsController.theme.addListener(() {
      setState(() => theme = DisplaySettingsController.theme.value);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            "Display",
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge!.color),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,  color: Theme.of(context).iconTheme.color),
            onPressed: () => context.pop('/setting_profile'),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Content Display",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 10),

              LabelSwitch(
                label: "Start with Sunday in calendar",
                value: startSunday,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => startSunday = v);
                  DisplaySettingsController.updateStartSunday(v);
                },
              ),

              const SizedBox(height: 14),
              LabelSwitch(
                label: "Add items from the top",
                value: addFromTop,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => addFromTop = v);
                  DisplaySettingsController.updateAddFromTop(v);
                },
              ),

              const SizedBox(height: 14),
              LabelSwitch(
                label: "Show time in 24 Hour Format",
                value: show24Hour,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => show24Hour = v);
                  DisplaySettingsController.updateShow24Hour(v);
                },
              ),

              const SizedBox(height: 14),
              LabelSwitch(
                label: "Show small photo in Phoenix item",
                value: showSmallPhoto,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => showSmallPhoto = v);
                  DisplaySettingsController.updateShowSmallPhoto(v);
                },
              ),

              const SizedBox(height: 14),
              LabelSwitch(
                label: "Show small memo of Phoenix item",
                value: showSmallMemo,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => showSmallMemo = v);
                  DisplaySettingsController.updateShowSmallMemo(v);
                },
              ),

              const SizedBox(height: 30),

              Text(
                "Appearance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 10),

              LabelSwitch(
                label: "Theme",
                value: theme,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                onChanged: (v) {
                  setState(() => theme = v);
                  DisplaySettingsController.updateTheme(v);
                },
              ),
            ],
          ),
        )
    );
  }
}
