import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class Api {
  var dio = Dio();

  Future downloadVideo(String id, Function showDownloadProgress) async {
    id = "382169007";
    var url = "https://player.vimeo.com/video/$id/config";
    Response response = await dio.get(url);
    String videomp4Url =
        response.data["request"]["files"]["progressive"][0]["url"];

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    CancelToken cancelToken = CancelToken();
    try {
      await dio.download(videomp4Url, "$path/videos/$id.mp4",
          onReceiveProgress: showDownloadProgress, cancelToken: cancelToken);
    } catch (e) {
      print(e);
    }
  }

  Future getVideoDownload(String id) async {
    id = "382169007";
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File localFile = File("$path/videos/$id.mp4");
    final bytes = await localFile.readAsBytes();
    print(bytes);
  }

  Future<String> getVideoUrl(String id) async {
    id = "382169007";
    var url = "https://player.vimeo.com/video/$id/config";
    Response response = await dio.get(url);
    String videomp4Url =
        response.data["request"]["files"]["progressive"][0]["url"];
    return videomp4Url;
  }

  Future<File> getVideoFile(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File localFile = File("$path/videos/$id.mp4");
    return localFile;
  }

  Future deleteVideo(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File localFile = File("$path/videos/$id.mp4");
    localFile.delete();
  }
}
