import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:light_control/device_screen.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard(
      {super.key, required this.device, required this.connectionIcon});

  final BluetoothDevice device;
  final Widget connectionIcon;
  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _value = false;
  late BluetoothCharacteristic writeCharacteristic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { _asyncMethod(); });
  }

  void _asyncMethod() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    writeCharacteristic = services[0].characteristics[0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _value = !_value;
        });
        if (_value) {
          writeCharacteristic.write([0x6f, 0x6e]);
        } else {
          writeCharacteristic.write([0x6f, 0x66, 0x66]);
        }
        HapticFeedback.lightImpact();
      },
      onLongPressStart: (details) {
        HapticFeedback.mediumImpact();
      },
      onLongPressEnd: (details) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DeviceScreen(
              deviceName: widget.device.name,
              writer: writeCharacteristic
            ),
          ),
        );
        HapticFeedback.heavyImpact();
      },
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemBackground.color,
            border:
                Border.all(color: CupertinoColors.secondarySystemBackground),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.secondarySystemBackground.darkColor
                    .withOpacity(0.1),
                offset: const Offset(-3.5, 3.5),
                spreadRadius: 1.0,
                blurRadius: 5.0,
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 7, 7, 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 4, 0),
                    child: widget.connectionIcon,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(
                        (_value)
                            ? CupertinoIcons.lightbulb_fill
                            : CupertinoIcons.lightbulb,
                        size: 50,
                        color: CupertinoColors.black,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.device.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
