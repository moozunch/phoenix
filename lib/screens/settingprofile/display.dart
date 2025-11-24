import 'package:flutter/material.dart';
import 'package:phoenix/widgets/label_switch.dart';
import 'package:go_router/go_router.dart';

class DisplayPage extends StatefulWidget{
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{
  bool startSunday = true;
  bool addFromTop = false;
  bool show24Hour = false;
  bool showSmallPhoto = false;
  bool showSmallMemo = false;
  bool theme = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Display",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop('/setting_profile'),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LabelSwitch(
              label: "Start with Sunday in calendar",
              value: startSunday,
              onChanged: (v) => setState(() => startSunday = v),
            ),

            SizedBox(height: 14),
            LabelSwitch(
              label: "Show time in 24 Hour Format",
              value: show24Hour,
              onChanged: (v) => setState(() => show24Hour = v),
            ),

            SizedBox(height: 14),
            LabelSwitch(
              label: "Show small photo in Phoenix item",
              value: showSmallPhoto,
              onChanged: (v) => setState(() => showSmallPhoto = v),
            ),

            SizedBox(height: 14),
            LabelSwitch(
              label: "Theme",
              value: theme,
              onChanged: (v) => setState(() => theme = v),
            ),
          ],
        ),
      )
    );
  }
}