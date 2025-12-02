import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiServices {
  // GET METHOD
  static Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": false,
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": false, "message": "Something went wrong: $e"};
    }
  }

  static Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": false,
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"status": false, "message": "Something went wrong: $e"};
    }
  }

  static Future<Map<String, dynamic>> multipartApi({
    required String url,
    required Map<String, String> fields,
    required File? file,
    required String fileField,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add normal fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add file
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            file.path,
          ),
        );
      }

      var response = await request.send();
      var resData = await http.Response.fromStream(response);

      return jsonDecode(resData.body);
    } catch (e) {
      return {"status": false, "message": "Something went wrong: $e"};
    }
  }

}
