import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import "./contact_card_screen.dart";
import "./contact_details.dart";

class DetailScreen extends StatefulWidget {
  final String imagePath;

  DetailScreen(this.imagePath);

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path);

  final String path;

  Size? _imageSize;
  List<TextElement> _elements = [];
  String recognizedEmail = "Loading...";
  String recognizedNumber = "";
  String recognizedName = "";
  String recognizedNotes = "";

  void _initializeVision() async {
    final File imageFile = File(path);

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    final inputImage = InputImage.fromFile(imageFile);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    String patternEmail =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

    RegExp regExEmail = RegExp(patternEmail);

    String patternNumber = r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$";

    RegExp regExNumber = RegExp(patternNumber);

    String patternName = r"(?:(?:[A-Z][a-z]+)\s?){1,3}";

    RegExp regExName = RegExp(patternName);

    String mailAddress = "";
    String phoneNumber = "";

    String name = "";
    List<String> notes = [];

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        if (regExEmail.hasMatch(line.text)) {
          mailAddress += line.text + '\, ';
        } else if (regExNumber.hasMatch(line.text)) {
          phoneNumber += line.text + ' ';
        } else if (regExName.hasMatch(line.text) && name.isEmpty) {
          name = line.text;
        } else {
          notes.add(line.text);
        }

        for (TextElement element in line.elements) {
          _elements.add(element);
        }
      }
    }

    if (this.mounted) {
      ContactDetails contactDetails = ContactDetails(
        name: name,
        email: mailAddress,
        phoneNumber: phoneNumber,
        notes: notes.join('\n'),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ContactCardScreen(contactDetails: contactDetails),
        ),
      );
    }
  }

  @override
  void dispose() {
    GoogleMlKit.vision.textDetector().close();
    super.dispose();
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

// Launch intent
  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print('could not launch $command');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Card Details"),
      ),
      body: _imageSize != null
          ? Center(
              child: Container(
                width: double.maxFinite,
                color: Colors.black,
                child: CustomPaint(
                  foregroundPainter:
                      TextDetectorPainter(_imageSize!, _elements),
                  child: AspectRatio(
                    aspectRatio: _imageSize!.aspectRatio,
                    child: Image.file(
                      File(path),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextElement container) {
      return Rect.fromLTRB(
        container.rect.left * scaleX,
        container.rect.top * scaleY,
        container.rect.right * scaleX,
        container.rect.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.elements != elements;
  }
}
