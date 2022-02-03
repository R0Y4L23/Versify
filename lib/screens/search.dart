// ignore_for_file: prefer_const_constructors_in_immutables, sized_box_for_whitespace, avoid_print, prefer_const_constructors

import 'dart:convert';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "../components/song.dart";

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String query = "";
  List tracks = [];
  String noListString = "Search Lyrics for a Song";

  void getSearchDataForTrack() async {
    var request = http.Request(
        'GET',
        Uri.parse('http://api.musixmatch.com/ws/1.1/track.search?q_track=' +
            query +
            '&page_size=20&page=1&f_has_lyrics=1&apikey=da204638e9d2b73b302f9e6108a29a1a'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String resultString = await response.stream.bytesToString();
      Map result = jsonDecode(resultString);
      setState(() {
        tracks = result["message"]["body"]["track_list"];
      });
      if (tracks.isEmpty) {
        setState(() {
          noListString = "No Results Found";
        });
      }
    } else {
      print(response.reasonPhrase);
    }
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
                    "Search For A Song",
                    style: TextStyle(
                      fontSize: adjustedSize(30),
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
            Container(
              padding: EdgeInsets.all(adjustedHeight(10)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange.shade400),
                  ),
                  hintText: "Search for a song",
                  hintStyle: TextStyle(
                    fontSize: adjustedSize(20),
                    color: Colors.orange.shade400,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(adjustedHeight(10))),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.orange.shade400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(adjustedHeight(10)),
              child: ElevatedButton(
                onPressed: () {
                  getSearchDataForTrack();
                },
                child: Text("Search"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.orange.shade400),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(5),
                ),
              ),
            ),
            tracks.isNotEmpty
                ? SizedBox(
                    height: adjustedHeight(445),
                    width: adjustedWidth(300),
                    child: ListView.builder(
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          return Song(
                              name: tracks[index]['track']["track_name"]
                                  .toString(),
                              artist: tracks[index]['track']["artist_name"]
                                  .toString(),
                              album: tracks[index]['track']['album_name']
                                  .toString(),
                              trackId: tracks[index]['track']["track_id"]);
                        }),
                  )
                : Container(
                    height: adjustedHeight(525),
                    width: adjustedWidth(300),
                    child: Center(
                      child: Text(
                        noListString,
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
