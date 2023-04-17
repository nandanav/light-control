import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_control/device_connection_card.dart';

class ConnectToDeviceScreen extends StatelessWidget {
  ConnectToDeviceScreen({super.key, required this.connectedDeviceCallback});

  final List<BluetoothDevice?> scannedDevices = [];
  final FlutterBluePlus instance = FlutterBluePlus.instance;
  final Function(BluetoothDevice) connectedDeviceCallback;

  connectToDeviceCallback(BluetoothDevice device, BuildContext context) {
    connectedDeviceCallback(device);
    instance.stopScan();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          child: const Icon(CupertinoIcons.back),
          onTap: () {
            instance.stopScan();
            Navigator.pop(context);
          },
        ),
        middle: const Text("Add Light Device"),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      child: StreamBuilder<ScanResult>(
        stream: instance.scan(timeout: const Duration(seconds: 30)),
        builder: (c, snapshot) {
          final scanResults = snapshot.data;
          final device = scanResults?.device;
          if ((scannedDevices.firstWhere((element) => element?.id == device?.id,
                      orElse: () => null)) ==
                  null &&
              device?.name == "Light Control") {
            // TODO: Change device?.name != '' to check if the device name contains a unique string that the microcontroller will emit
            scannedDevices.add(device);
          }
          return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
              children: scannedDevices
                  .whereType<BluetoothDevice>()
                  .map(
                    (device) => DeviceConnectionCard(
                      device: device,
                      connectToDeviceCallback: connectToDeviceCallback,
                      parentContext: context,
                    ),
                  )
                  .toList());
        },
      ),
    );
  }
}
