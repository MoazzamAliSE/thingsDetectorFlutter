import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;

  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;

  var cameraCount = 0;
  double x = 0.0;
  double y = 0.0;
  double w = 0.0;
  double h = 0.0;
  var label = '';

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max,
          imageFormatGroup: ImageFormatGroup.unknown);
      await cameraController.initialize().then(
        (value) {
          cameraController.startImageStream((image) {
            cameraCount++;
            if (cameraCount % 10 == 0) {
              cameraCount = 0;
              objectDetection(image);
            }
            update();
          });
        },
      );
      isCameraInitialized(true);
      update();
    } else {
      print("Permision denied");
    }
  }

  objectDetection(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) => e.bytes).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );
    if (detector != null || detector!.isNotEmpty) {
      var ourDetectedObject = await detector.first;
      if (ourDetectedObject['confidenceInClass'] * 100 > 45) {
        label = detector.first['detectedClass'].toString();
        h = ourDetectedObject['rect']
            ['h']; //The positions of detected object is rect
        w = ourDetectedObject['rect']['w'];
        x = ourDetectedObject['rect']['x'];
        y = ourDetectedObject['rect']['y'];
      }
      update();
      log("Result is $detector");
    }
  }
}
