import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remove_bg_example/api_client.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RemoveBackground(),
    ),
  );
}

class RemoveBackground extends StatefulWidget {
  @override
  _RemoveBackgroundState createState() => new _RemoveBackgroundState();
}

class _RemoveBackgroundState extends State<RemoveBackground> {
//image file
  Uint8List? imageFile;
  //image path
  String? imagePath;
  //controller
  ScreenshotController controller = ScreenshotController();
  //toast
  toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Bg'),
        actions: [
          IconButton(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.image)),
          IconButton(
              onPressed: () {
                getImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt)),
          // IconButton(
          //     onPressed: () async {

          //       toastMessage("Please Wait");
          //       imageFile = await ApiClient().removeBgApi(imagePath!);

          //       setState(() {});
          //     },
          //     icon: const Icon(Icons.delete)),
          // IconButton(
          //     onPressed: () {
          //       saveImage();
          //     },
          //     icon: const Icon(Icons.save))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imageFile != null)
                ? Screenshot(
                    controller: controller, child: Image.memory(imageFile!))
                : Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                    child: const Icon(
                      Icons.image,
                      size: 100,
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SpeedDial(
          speedDialChildren: [
            //Remove Background
            SpeedDialChild(
              child: const Icon(Icons.wallpaper),
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              label: 'Remove Background',
              onPressed: () async {
                toastMessage("Please Wait");
                imageFile = await ApiClient().removeBgApi(imagePath!);

                setState(() {});
              },
            ),
            //Save Image
            SpeedDialChild(
              child: const Icon(Icons.lock),
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              label: 'Save Image',
              onPressed: () {
                saveImage();
              },
            ),
          ],
          closedForegroundColor: Colors.red,
          openForegroundColor: Colors.red,
          closedBackgroundColor: Colors.red,
          openBackgroundColor: Colors.red,
          labelsBackgroundColor: Colors.orange,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }

  void saveImage() async {
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }
    if (isGranted) {
      String fileName = DateTime.now().toString();
      controller.capture().then((Uint8List? image) {
        ImageGallerySaver.saveImage(image!, quality: 60, name: fileName);
        toastMessage("Successfully Downloaded On Gallary");
      });
    }
  }
}
