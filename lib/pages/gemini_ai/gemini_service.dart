import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey =
      "AIzaSyAHQfvJG_4tnw2r2DzVCQNUo6D4WwFIejg"; // ใส่ API Key ของคุณ

  Future<String> askGemini(String prompt) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    int retries = 0;
    while (retries < 3) {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else if (response.statusCode == 503) {
        // ลองใหม่แบบ backoff
        await Future.delayed(Duration(seconds: 2 * (retries + 1)));
        retries++;
      } else {
        throw Exception(
            "Gemini Error ${response.statusCode}: ${response.body}");
      }
    }

    throw Exception("Gemini 503: ลองหลายครั้งแล้ว แต่ยังไม่สำเร็จ");
  }
}
