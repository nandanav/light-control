import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceConnectionCard extends StatefulWidget {
  const DeviceConnectionCard(
      {super.key, required this.device, required this.connectToDeviceCallback, required this.parentContext});

  final BluetoothDevice device;
  final Function(BluetoothDevice, BuildContext) connectToDeviceCallback;
  final BuildContext parentContext;

  @override
  State<DeviceConnectionCard> createState() => _DeviceConnectionCardState();
}

class _DeviceConnectionCardState extends State<DeviceConnectionCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        widget.device.connect();
        setState(() {
          widget.connectToDeviceCallback(widget.device, widget.parentContext);
        });
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
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 6, 4, 0),
                    child: Icon(
                      CupertinoIcons.bluetooth,
                      color: CupertinoColors.black,
                    ),
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
                      const Icon(
                        CupertinoIcons.lightbulb,
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
