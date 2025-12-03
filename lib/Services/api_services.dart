import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;


class ApiServices {
  // GET METHOD
  static Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint("GET API Response: ${response.statusCode}");
      debugPrint("GET API Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {
            "message": response.body,
            "code": 200,
          };
        }
      } else {
        return {
          "code": response.statusCode,
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "code": 500,
        "message": "Something went wrong: $e"
      };
    }
  }

  static Future<Map<String, dynamic>> postApi(
      String url,
      Map<String, dynamic> body,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      debugPrint("POST API URL: $url");
      debugPrint("POST API Body Sent: $body");
      debugPrint("POST API Response Status: ${response.statusCode}");
      debugPrint("POST API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          // If response is not valid JSON, return as text
          return {
            "message": response.body,
            "code": 200,
          };
        }
      } else {
        return {
          "code": response.statusCode,
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "code": 500,
        "message": "Something went wrong: $e"
      };
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

      // Add form fields
      request.fields.addAll(fields);

      // Add file if exists
      if (file != null && file.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
      }

      var response = await request.send();
      var resData = await http.Response.fromStream(response);

      debugPrint("Multipart API Response Status: ${response.statusCode}");
      debugPrint("Multipart API Response Body: ${resData.body}");

      if (response.statusCode == 200) {
        try {
          return jsonDecode(resData.body);
        } catch (e) {
          return {
            "message": resData.body,
            "code": 200,
          };
        }
      } else {
        return {
          "code": response.statusCode,
          "message": "Server error ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "code": 500,
        "message": "Something went wrong: $e"
      };
    }
  }
}

// Add this import at the top of the file
void debugPrint(String message) {
  developer.log(message, name: 'ApiServices');
}