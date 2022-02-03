// ignore_for_file: prefer_const_constructors

import "package:flutter/material.dart";
import "../screens/result.dart";

class Song extends StatelessWidget {
  const Song(
      {Key? key,
      required this.name,
      required this.artist,
      required this.album,
      required this.trackId})
      : super(key: key);

  final String name;
  final String artist;
  final String album;
  final int trackId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: EdgeInsets.only(left: 20, top: 10, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.headline6),
            SizedBox(
              height: 5,
            ),
            Text(artist, style: Theme.of(context).textTheme.subtitle1),
            SizedBox(
              height: 5,
            ),
            Text(album, style: Theme.of(context).textTheme.subtitle2),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Result(trackId: trackId)));
      },
    );
  }
}
