import 'package:audiobook_demo/bloc/music_bloc/music_bloc.dart';
import 'package:audiobook_demo/bloc/observor.dart';
import 'package:audiobook_demo/bloc/player_bloc/player_bloc.dart';
import 'package:audiobook_demo/models/song.dart';
import 'package:audiobook_demo/views/nav_bar_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

final player = AudioPlayer();
bool isSongPlaying = false;
bool isSongStarted = false;
bool isSongLoading = true;
late AudioModel playingSongFile;
Duration? playingSongDuration;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Musify playback',
    androidNotificationOngoing: true,
  );
  BlocOverrides.runZoned(() => runApp(const MyApp()),
  blocObserver: SimpleBlocObserver());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_)=>MusicBloc()..add(MusicDataFetched())),
          BlocProvider(create: (_)=>AudioPlayerBloc())
        ],
        child: MaterialApp(
      title: 'Musify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.orange
      ),
      home: NavigationBarHomePage(),
    ));
  }
}
