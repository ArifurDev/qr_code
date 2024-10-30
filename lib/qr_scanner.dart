import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedCode;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedCode = scanData.code;
      });
      controller.stopCamera();
      if (scannedCode != null) {
        _checkQrCode(scannedCode!);
      }
    });
  }

  Future<void> _checkQrCode(String code) async {
    final response = await http.get(
      Uri.parse('http://aionpartydashboard.altervista.org/api/qrcode/check/$code'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking QR code')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
          ),
          if (scannedCode != null)
            Center(
              child: Text(
                'Scanned Code: $scannedCode',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
