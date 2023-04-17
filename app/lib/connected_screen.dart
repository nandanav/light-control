import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOnScreen extends StatelessWidget {
    const BluetoothOnScreen({Key? key, this.state}) : super(key: key);

    final BluetoothState? state;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.blue,
            appBar: AppBar(
                elevation: 0, 
                title: const Text("Find Devices"),
                actions: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                        ),
                        onPressed: null,
                        child: const Text("Turn off"),
                    ),
                ],
            ),
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Icon(
                            Icons.bluetooth_searching,
                            size: 200.0,
                            color: Colors.white54,
                        ),
                        const SizedBox(height: 12),
                        Text('Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
                        style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),),
                    ],
                )
            )
        );
    }
}