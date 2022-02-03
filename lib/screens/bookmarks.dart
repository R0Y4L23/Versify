// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'dart:convert';

import "package:flutter/material.dart";
import "../components/song.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:fluttertoast/fluttertoast.dart";

class Bookmarks extends StatefulWidget {
  Bookmarks({Key? key}) : super(key: key);

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<String> bookmarkedTracksList = [];

  void getBookmarkedTracks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bookmarkedTracks = prefs.getStringList('bookmarkedTracks');
    if (bookmarkedTracks != null) {
      setState(() {
        bookmarkedTracksList = bookmarkedTracks;
      });
    }
  }

  void removeBookmarked(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bookmarkedTracks = prefs.getStringList('bookmarkedTracks');
    if (bookmarkedTracks != null) {
      setState(() {
        bookmarkedTracksList = bookmarkedTracks;
      });
    }
    setState(() {
      bookmarkedTracksList.removeAt(index);
    });
    prefs.setStringList('bookmarkedTracks', bookmarkedTracksList);
    Fluttertoast.showToast(
        msg: "Track removed from bookmarks",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void initState() {
    super.initState();
    getBookmarkedTracks();
  }

  @override
  Widget build(BuildContext context) {
    double dWidth = MediaQuery.of(context).size.width;
    double dHeight = MediaQuery.of(context).size.height;
    adjustedWidth(double width) {
      return width * dWidth / 375;
    }

    adjustedHeight(double height) {
      return height * dHeight / 667;
    }

    adjustedSize(double size) {
      return (((size * dWidth) / 375) + ((size * dHeight) / 667)) / 2;
    }

    return Scaffold(
        body: Container(
      height: dHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8), BlendMode.softLight),
          image: AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
            Container(
              padding: EdgeInsets.all(adjustedHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bookmarks",
                    style: TextStyle(
                      fontSize: adjustedSize(40),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade400,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.orange.shade400,
                      ))
                ],
              ),
            ),
            bookmarkedTracksList.isNotEmpty
                ? SizedBox(
                    height: adjustedHeight(575),
                    width: adjustedWidth(300),
                    child: ListView.builder(
                        itemCount: bookmarkedTracksList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Song(
                                  name: jsonDecode(bookmarkedTracksList[index])[
                                      "track_name"],
                                  artist:
                                      jsonDecode(bookmarkedTracksList[index])[
                                          "artist_name"],
                                  album:
                                      jsonDecode(bookmarkedTracksList[index])[
                                          'album_name'],
                                  trackId: jsonDecode(
                                      bookmarkedTracksList[index])["track_id"]),
                              IconButton(
                                onPressed: () {
                                  removeBookmarked(index);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade400,
                                ),
                              )
                            ],
                          );
                        }),
                  )
                : Container(
                    height: adjustedHeight(525),
                    width: adjustedWidth(300),
                    child: Center(
                      child: Text(
                        "No bookmarks yet!",
                        style: TextStyle(
                          fontSize: adjustedSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
          ]))),
    ));
  }
}
