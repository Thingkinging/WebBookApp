import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_book_app/data/book.dart';
import 'package:web_book_app/favorite_screen.dart';

class BooksHelper {
  final String urlKey = '&key=AIzaSyCBpGeeExnTwgDDeGzzC6X5cMbSFVznGBQ';
  final String urlQuery = 'volumes?q=';
  final String urlBase = 'https://www.googleapis.com/books/v1/';

  Future<List<dynamic>> getBooks(String query) async {
    final String url = urlBase + urlQuery + query + urlKey;
    Response result = await http.get(Uri.parse(url));

    if (result.statusCode == 200) {
      final jsonResponse = json.decode(result.body);
      final booksMap = jsonResponse['items'];
      List<dynamic> books = booksMap.map((i) => Book.fromJson(i)).toList();

      return books;
    } else {
      // ignore: null_check_always_fails
      return null!;
    }
  }

  Future addToFavorites(Book book) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(book.id);
    if (id != '') {
      await preferences.setString(book.id, json.encode(book.toJson()));
    }
  }

  Future removeFromFavorites(Book book, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(book.id);
    if (id != '') {
      await preferences.remove(book.id);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FavoriteScreen()));
    }
  }

  Future<List<dynamic>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> favBooks = [];
    Set allKeys = prefs.getKeys();
    if (allKeys.isNotEmpty) {
      for (int i = 0; i < allKeys.length; i++) {
        String key = allKeys.elementAt(i).toString();
        String value = prefs.get(key) as String;
        dynamic json = jsonDecode(value);

        Book book = Book(json['id'], json['title'], json['authors'],
            json['description'], json['publisher']);

        favBooks.add(book);
      }
    }
    return favBooks;
  }
}
