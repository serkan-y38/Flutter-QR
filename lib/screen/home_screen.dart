import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_qr/navigation/nav_route.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 32,
              ),
              Icon(
                Icons.qr_code_2_rounded,
                size: 224,
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                maxLines: null,
                controller: _textEditingController,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  hintText: "Enter text",
                  labelText: "Enter Text To Generate QR Code",
                  prefixIcon: const Icon(Icons.data_object),
                  border: const UnderlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextButton(
                onPressed: () {
                  (_textEditingController.text != "")
                      ? _showQRCode()
                      : WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Enter Text To Generate QR Code")));
                        });
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  "Generate QR Code",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, NavRoute.qrCodeScannerScreen);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  "Scan QR Code",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQRCode() {
    return showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return GenerateQRBottomSheet(
          text: _textEditingController.text,
        );
      },
    );
  }
}

class GenerateQRBottomSheet extends StatefulWidget {
  final String text;

  const GenerateQRBottomSheet({
    super.key,
    required this.text,
  });

  @override
  State<StatefulWidget> createState() {
    return _Content();
  }
}

class _Content extends State<GenerateQRBottomSheet> {
  late QrCode _qrCode;
  late QrImage _qrImage;

  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _qrCode = QrCode.fromData(
      data: widget.text,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    _qrImage = QrImage(_qrCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: RepaintBoundary(
                key: _globalKey,
                child: PrettyQrView(
                  qrImage: _qrImage,
                  decoration: PrettyQrDecoration(
                    background: Colors.transparent,
                    quietZone: PrettyQrQuietZone.zero,
                    shape: PrettyQrSmoothSymbol(
                      color: Theme.of(context).colorScheme.onSurface,
                      roundFactor: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: TextButton(
              onPressed: () {
                save();
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                "Save QR Code",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: TextButton(
              onPressed: () {
                share();
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                "Share QR Code",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          )
        ],
      ),
    );
  }

  void share() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();

      final file = File(
          '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png');

      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'QR code',
      ));

      await file.delete();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  void save() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes, album: 'QR Codes');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("QR code saved to gallery")));
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }
}
