import 'dart:typed_data';

import 'package:cropperx/cropperx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropperX Example',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: const CropperScreen(),
    );
  }
}

class CropperScreen extends StatefulWidget {
  const CropperScreen({Key? key}) : super(key: key);

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');
  Uint8List? _imageToCrop;
  Uint8List? _croppedImage;
  OverlayType _overlayType = OverlayType.circle;
  int _rotationTurns = 0;


  void pickFiles() async {
    try {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) =>
            print("FilePickerStatus : $status"),
      );
      if(kIsWeb) {
        _setState(result?.files.first.bytes);
      } else {
        var filePath = result?.files.first.path;
        if(filePath != null) {
          var file = XFile(filePath);
          _setState(await file.readAsBytes());
        }
      }

    } on PlatformException catch (e) {
      debugPrint('Unsupported operation$e');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _setState(Uint8List? uint8list) {
    setState(() {
      _imageToCrop = uint8list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 500,
                child: _imageToCrop != null
                    ? Cropper(
                        cropperKey: _cropperKey,
                        overlayType: _overlayType,
                        rotationTurns: _rotationTurns,
                        image: Image.memory(_imageToCrop!),
                        onScaleStart: (details) {
                          // todo: define started action.
                        },
                        onScaleUpdate: (details) {
                          // todo: define updated action.
                        },
                        onScaleEnd: (details) {
                          // todo: define ended action.
                        },
                      )
                    : const ColoredBox(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  ElevatedButton(
                    child: const Text('Pick image'),
                    onPressed: pickFiles,
                  ),
                  ElevatedButton(
                    child: const Text('Switch overlay'),
                    onPressed: () {
                      // setState(() {
                      //   _overlayType = _overlayType == OverlayType.circle
                      //       ? OverlayType.grid
                      //       : _overlayType == OverlayType.grid
                      //           ? OverlayType.rectangle
                      //           : OverlayType.circle;
                      // });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Crop image'),
                    onPressed: () async {
                      final imageBytes = await Cropper.crop(
                        cropperKey: _cropperKey,
                      );

                      if (imageBytes != null) {
                        setState(() {
                          _croppedImage = imageBytes;
                        });
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _rotationTurns--);
                    },
                    icon: const Icon(Icons.rotate_left),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _rotationTurns++);
                    },
                    icon: const Icon(Icons.rotate_right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_croppedImage != null)
                Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Image.memory(_croppedImage!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
