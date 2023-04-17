import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/gen/flutterblueplus.pbjson.dart';
import 'package:light_control/device_card.dart';
import 'package:light_control/disconnected_screen.dart';
import 'package:light_control/connect_to_devices_screen.dart';
// import 'connected_screen.dart';
// import 'disconnected_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Personal Light Control',
      theme: const CupertinoThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primaryColor: Colors.white,
          primaryContrastingColor: Colors.deepPurpleAccent,
          scaffoldBackgroundColor: Colors.white),
      home: Home(
        instance: FlutterBluePlus.instance,
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, this.instance});

  final FlutterBluePlus? instance;

  @override
  State<Home> createState() => _HomeState();
}

// Code to display bluetooth devices
//

class _HomeState extends State<Home> {
  final List<BluetoothDevice> connectedDevices = [];

  addConnectedDevice(BluetoothDevice device) {
    setState(() {
      connectedDevices.add(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Choose Light Device"),
        trailing: GestureDetector(
          child: const Icon(CupertinoIcons.add),
          onTap: () {
            connectedDevices.clear();
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ConnectToDeviceScreen(
                        connectedDeviceCallback: addConnectedDevice)));
          },
        ),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      // child: const Center(
      //   child: DeviceCard(
      //     device: "Testing",
      //     connectionIcon: Icon(CupertinoIcons.bluetooth),
      //   ),
      // )
      child: StreamBuilder(
        stream: widget.instance?.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 5))
                  .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
              initialData: const [],
              builder: (context, snapshot) => GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
                children: snapshot.data!
                    .where((d) => d.name.contains("Light Control"))
                    .map(
                      (d) => DeviceCard(
                        device: d,
                        connectionIcon: StreamBuilder<BluetoothDeviceState>(
                          stream: d.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (context, snapshot) => Icon(
                            CupertinoIcons.bluetooth,
                            color: (snapshot.data == null)
                                ? CupertinoColors.black
                                : (snapshot.data ==
                                        BluetoothDeviceState.connected)
                                    ? CupertinoColors.systemGreen
                                    : (snapshot.data ==
                                            BluetoothDeviceState.disconnected)
                                        ? CupertinoColors.systemRed
                                        : (snapshot.data ==
                                                BluetoothDeviceState
                                                    .disconnecting)
                                            ? CupertinoColors.systemYellow
                                            : CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          } else {
            return const BluetoothOffScreen();
          }
        },
      ),
    );
  }
}
