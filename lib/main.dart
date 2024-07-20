import 'package:flutter/material.dart';
import 'package:roslibdart/roslibdart.dart';
import 'dart:typed_data';

void main() {
  runApp(Robot_GUI());
}

class Robot_GUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot GUI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Robot Camera Feed'),
        ),
        body: ROSImageWidget(),
      ),
    );
  }
}

class ROSImageWidget extends StatefulWidget {
  @override
  _ROSImageWidgetState createState() => _ROSImageWidgetState();
}

class _ROSImageWidgetState extends State<ROSImageWidget> {
  late Topic imageTopic;
  Uint8List? imageData; // nullable に変更
  late Ros ros;

  @override
  void initState() {
    super.initState();
    initConnection();
  }

  Future<void> initConnection() async {
    ros = Ros(url: 'ws://localhost:9090');
    try {
      ros.connect(); // await を追加
      print('Connected to ROS');

      imageTopic = Topic(
        ros: ros,
        name: '/image_raw',
        type: "sensor_msgs/Image",
        reconnectOnClose: true,
        queueSize: 10,
        queueLength: 10,
      );

      Future<void> subscribeHandler(Map<String, dynamic> msg) async {
        if (mounted) {
          setState(() {
            imageData = Uint8List.fromList(msg['data'] as List<int>);
          });
        }
      }

      await imageTopic.subscribe(subscribeHandler);
    } catch (e) {
      print('Error connecting to ROS: $e');
      // エラーハンドリングを改善する場合、ここでユーザーに通知するなどの処理を追加
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: imageData != null
          ? Image.memory(imageData!) // null チェック後に ! を使用
          : CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    imageTopic.unsubscribe(); // ? を削除
    ros.close(); // ? を削除
    super.dispose();
  }
}
