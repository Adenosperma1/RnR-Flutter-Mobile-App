import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class FileHelper {

//-------------------------------------------------------------------//
Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }//end localPath

//-------------------------------------------------------------------//
Future<File> writeFile(String name, String data) async {
  final path = await _localPath;
   final file = File('$path/$name');
  return file.writeAsString('$data');
}

//-------------------------------------------------------------------//
Future<String> readFile(File file) async {
  try {
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    return null;
  }
}





}//end class
