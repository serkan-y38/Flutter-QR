import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _QRCodeScannerScreen();
  }
}

class _QRCodeScannerScreen extends State<QRCodeScannerScreen> {
  String _result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              setState(() {
                _result = barcode.rawValue ?? "No Data found in QR";
              });
            }
          }),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    width: 4,
                  ),
                ),
              ),
            ),
          ),
          if (_result != "")
            Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SelectableText(
                      _result,
                      style: isValidLink(_result)
                          ? const TextStyle(color: Colors.blue)
                          : const TextStyle(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool isValidLink(String input) {
    final uri = Uri.tryParse(input);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) &&
        uri.host.isNotEmpty;
  }
}
