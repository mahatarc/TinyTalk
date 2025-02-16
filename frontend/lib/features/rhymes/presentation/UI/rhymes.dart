import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RhymesPage extends StatelessWidget {
  const RhymesPage({super.key});

  final List<Map<String, String>> videos = const [
    {"title": "एक दुई तीन", "id": "NGdJxP7EXe4"},
    {"title": "क बाट कछुवा", "id": "1eH6S7HzjDU"},
    {"title": "अ बाट अनार", "id": "VPr1BD1isE4"},
    {"title": "सयौं थुँगा फूलका | National Anthem of Nepal", "id": "xaCnY8Bj7ww"},
    {"title": "चि मुसी चि", "id": "OquL143cnQw"},
    {"title": "कुखुरी काँ", "id": "zi11MAkhqx4"},
    {"title": "चिडियाखाना घुम्न जाऔं", "id": "uCvk3DZVwxA"},
    {"title": "Baby Shark Doo Doo", "id": "faBbwMK6XuI"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Rhymes"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/backg.jpg', // Background image
              fit: BoxFit.cover,
            ),
          ),
          ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              String videoThumbnailUrl =
                  'https://img.youtube.com/vi/${videos[index]["id"]}/0.jpg';

              return SizedBox(
                height: 100.0,
                child: Card(
                  color: const Color.fromARGB(255, 233, 194, 148),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(
                      color: Color(0xFFC57F27),
                      width: 2.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: SizedBox(
                      width: 130.0,
                      height: 600.0,
                      child: Image.network(
                        videoThumbnailUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(videos[index]["title"]!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerPage(videoId: videos[index]["id"]!),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait = constraints.maxWidth < constraints.maxHeight;
          
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'images/backg.jpg', // Background image
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // If portrait mode, set the video height to 35% of the screen height.
                    // If landscape mode, make the video take up the entire screen.
                    Container(
                      width: constraints.maxWidth, // Full width of the screen
                      height: isPortrait 
                          ? constraints.maxHeight * 0.35 // 35% of height in portrait
                          : constraints.maxHeight, // Full height in landscape
                      child: YoutubePlayer(
                        controller: _youtubePlayerController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}