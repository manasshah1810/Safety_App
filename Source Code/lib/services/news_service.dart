// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Add your API key here
const String apiKey = 'e32291bc90964f209e8f4b770a9b5dd8';

Future<List<dynamic>> fetchNews() async {
  // Define the query for news
  String query = "scam OR harassment OR theft OR rape OR crime";

  // URL for the NewsAPI with the API key
  String url = 'https://newsapi.org/v2/everything?q=$query&domains=timesofindia.indiatimes.com,ndtv.com&language=en&apiKey=$apiKey';

  // Make the GET request
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body)['articles']; // Adjust according to your API response
  } else {
    throw Exception('Failed to load news');
  }
}

