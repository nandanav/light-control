import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_native_colorpicker/flutter_native_colorpicker.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.deviceName, required this.writer});

  final String deviceName;
  final BluetoothCharacteristic writer;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  GlobalKey key = GlobalKey();
  Color _color = CupertinoColors.black;
  bool _setAllLED = false;
  StreamSubscription? listener;
  ValueNotifier<List<Color>> ledColors =
      ValueNotifier<List<Color>>(List.filled(30, CupertinoColors.white));

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          child: const Icon(CupertinoIcons.back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        middle: Text(widget.deviceName),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    key: key,
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    decoration: BoxDecoration(
                      color: _color,
                      border: Border.all(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    openColorPicker();
                  },
                ),
                CupertinoSwitch(value: _setAllLED, onChanged: (bool value) {
                  setState(() {
                    _setAllLED = value;
                  });
                  if (_setAllLED) {
                    List<Color> newList = List.filled(ledColors.value.length, _color);
                    ledColors.value = newList;
                    widget.writer.write([
                          0x73,
                          0x65,
                          0x74,
                          0x41,
                          0x6c,
                          0x6c,
                          0x20,
                          ..._color.value
                              .toRadixString(16)
                              .padLeft(6)
                              .split('')
                              .skip(2)
                              .join('')
                              .codeUnits,
                        ]);
                  }
                }),
              ],
            ),
            Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              decoration: const BoxDecoration(
                color: CupertinoColors.extraLightBackgroundGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: ValueListenableBuilder<List<Color>>(
                valueListenable: ledColors,
                builder: (context, List<Color> colors, Widget? child) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: LedLight(color: colors[index]),
                        onTap: () {
                          List<Color> newList = List.from(colors);
                          newList[index] = _color;
                          ledColors.value = newList;
                          widget.writer.write([0x73, 0x65, 0x74, 0x20, ..._color.value
                                .toRadixString(16)
                                .padLeft(6)
                                .split('')
                                .skip(2)
                                .join('')
                                .codeUnits, 0x20, ...index.toRadixString(10).padLeft(2, '0').codeUnits
                          ]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openColorPicker() async {
    final box = key.currentContext?.findRenderObject();

    if (box is! RenderBox) {
      throw StateError('Render object is not a render box');
    }

    final position = box.localToGlobal(Offset.zero);

    FlutterNativeColorpicker.open(position & box.size);
    listener = FlutterNativeColorpicker.startListener((col) => {
          setState(() {
            _color = col;
            if (_setAllLED) {
              List<Color> newList = List.filled(ledColors.value.length, _color);
              ledColors.value = newList;
              widget.writer.write([
                0x73,
                0x65,
                0x74,
                0x41,
                0x6c,
                0x6c,
                0x20,
                ..._color.value
                    .toRadixString(16)
                    .padLeft(6)
                    .split('')
                    .skip(2)
                    .join('')
                    .codeUnits,
              ]);
            }
          })
        });
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }
}

class LedLight extends StatelessWidget {
  const LedLight({super.key, required this.color});

  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 30,
      color: color,
    );
  }
}
