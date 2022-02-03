// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, unused_import, avoid_print, no_logic_in_create_state, must_be_immutable, unused_element

import 'dart:convert';
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:fluttertoast/fluttertoast.dart";

class Result extends StatefulWidget {
  Result({Key? key, required this.trackId}) : super(key: key);

  int trackId;

  @override
  State<Result> createState() => _ResultState(trackId: trackId);
}

class _ResultState extends State<Result> {
  _ResultState({required this.trackId});
  int trackId;
  String lyrics = "Loading...";
  String trackName = "Loading...";
  String artistName = "Loading...";
  String albumName = "Loading...";

  void bookmarkTrack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map track = {
      "track_id": trackId,
      "track_name": trackName,
      "artist_name": artistName,
      "album_name": albumName,
    };
    List<String>? bookmarkedTracks = prefs.getStringList('bookmarkedTracks');
    bookmarkedTracks ??= <String>[];
    if (!bookmarkedTracks.contains(jsonEncode(track))) {
      bookmarkedTracks.add(jsonEncode(track));
      prefs.setStringList('bookmarkedTracks', bookmarkedTracks);
      Fluttertoast.showToast(
          msg: "Track Bookmarked",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Track Already Bookmarked",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void getTrackData() async {
    var request = http.Request(
        'GET',
        Uri.parse('http://api.musixmatch.com/ws/1.1/track.get?track_id=' +
            trackId.toString() +
            '&apikey=da204638e9d2b73b302f9e6108a29a1a'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      var jsonData = json.decode(data);
      var track = jsonData["message"]["body"]["track"];
      setState(() {
        trackName = track["track_name"];
        artistName = track["artist_name"];
        albumName = track["album_name"];
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void getTrackLyrics() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'http://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=' +
                trackId.toString() +
                '&apikey=da204638e9d2b73b302f9e6108a29a1a'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      var jsonData = json.decode(data);
      var track = jsonData["message"]["body"]["lyrics"]["lyrics_body"];
      setState(() {
        lyrics = track;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    getTrackData();
    getTrackLyrics();
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
                image: AssetImage("assets/resultBackground.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
                child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: adjustedWidth(20), top: adjustedHeight(20)),
                      width: adjustedWidth(300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Text(
                              trackName,
                              style: TextStyle(
                                  fontSize: adjustedSize(30),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Quintessential"),
                            ),
                            width: adjustedWidth(250),
                          ),
                          IconButton(
                              onPressed: () {
                                bookmarkTrack();
                              },
                              icon: Icon(
                                Icons.bookmark_add,
                                size: adjustedSize(30),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: adjustedWidth(20),
                          right: adjustedWidth(20),
                          top: adjustedHeight(20)),
                      child: Text(
                        "-" + artistName,
                        style: TextStyle(
                          fontSize: adjustedSize(15),
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: adjustedWidth(20),
                          right: adjustedWidth(20),
                          top: adjustedHeight(20)),
                      child: Text(
                        "Album: " + albumName,
                        style: TextStyle(
                            fontSize: adjustedSize(20),
                            fontWeight: FontWeight.bold,
                            fontFamily: "SupermercadoOne"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: adjustedWidth(30),
                          right: adjustedWidth(10),
                          top: adjustedHeight(20)),
                      child: Text(
                        lyrics.split("*******")[0],
                        style: TextStyle(
                            fontSize: adjustedSize(30),
                            fontWeight: FontWeight.bold,
                            fontFamily: "Pacifico"),
                      ),
                    ),
                  ],
                ),
              ),
            ))));
  }
}
