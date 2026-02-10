import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UsageScreen(),
    );
  }
}

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {

  static const platform = MethodChannel('app.usage');

  List<AppInfo> apps = [];

  Future<void> loadUsage() async {

    final result =
    await platform.invokeMethod('getUsageStats');

    final installed =
    await InstalledApps.getInstalledApps(true, true);

    List<AppInfo> temp = [];

    result.forEach((pkg, time) {

      final app =
      installed.where((a) => a.packageName == pkg);

      if (app.isNotEmpty && time > 0) {

        temp.add(AppInfo(
          name: app.first.name,
          icon: app.first.icon!,
          minutes: (time / 60000),
        ));
      }
    });

    setState(() {
      apps = temp;
    });
  }

  double get totalTime {
    double t = 0;
    for (var a in apps) {
      t += a.minutes;
    }
    return t;
  }

  @override
  void initState() {
    super.initState();
    loadUsage();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Wellbeing Pro"),
      ),
      body: Column(
        children: [

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: apps.take(5).map((e) {
                  return PieChartSectionData(
                    value: e.minutes,
                    title: e.name,
                  );
                }).toList(),
              ),
            ),
          ),

          Text(
            "Total Screen Time: ${totalTime.toStringAsFixed(1)} min",
            style: const TextStyle(fontSize: 18),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (c, i) {

                final app = apps[i];

                return ListTile(
                  leading:
                  Image.memory(app.icon, width: 40),
                  title: Text(app.name),
                  subtitle: Text(
                      "${app.minutes.toStringAsFixed(1)} minutes"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AppInfo {

  String name;
  Uint8List icon;
  double minutes;

  AppInfo({
    required this.name,
    required this.icon,
    required this.minutes,
  });
}
