// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, unused_element, sized_box_for_whitespace

import 'dart:convert';
import "package:flutter/material.dart";
import "../components/song.dart";
import "./bookmarks.dart";
import "./search.dart";
import "package:http/http.dart" as http;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List tracks = [];

  void getTrackData() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.musixmatch.com/ws/1.1/chart.tracks.get?chart_name=top&page=1&page_size=50&f_has_lyrics=1&apikey=da204638e9d2b73b302f9e6108a29a1a'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String resultString = await response.stream.bytesToString();
      Map result = jsonDecode(resultString);
      setState(() {
        tracks = result["message"]["body"]["track_list"];
      });
    } else {
      print("Error");
    }
  }

  @override
  void initState() {
    super.initState();
    getTrackData();
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
                    "Versify",
                    style: TextStyle(
                      fontSize: adjustedSize(40),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade400,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search()));
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.orange.shade400,
                          )),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Bookmarks()));
                          },
                          icon: Icon(
                            Icons.bookmark,
                            color: Colors.orange.shade400,
                          ))
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: adjustedHeight(10),
                  left: adjustedWidth(18),
                  bottom: adjustedHeight(30)),
              child: Text("Top 50 Tracks",
                  style: TextStyle(
                      fontSize: adjustedSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade500)),
            ),
            tracks.isNotEmpty
                ? SizedBox(
                    height: adjustedHeight(525),
                    width: adjustedWidth(300),
                    child: ListView.builder(
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          return Song(
                              name: tracks[index]["track"]["track_name"],
                              artist: tracks[index]["track"]["artist_name"],
                              album: tracks[index]["track"]['album_name'],
                              trackId: tracks[index]["track"]["track_id"]);
                        }),
                  )
                : Container(
                    height: adjustedHeight(525),
                    width: adjustedWidth(300),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ]))),
    ));
  }
}
