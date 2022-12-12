import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audiobook_demo/bloc/player_bloc/player_bloc.dart';
import 'package:audiobook_demo/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:audiobook_demo/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

class PlayerScreen extends StatefulWidget {
  PlayerScreen({Key? key,}) : super(key: key);
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}


class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin{

  late final AnimationController _animationController;
  String maxduration = '00:00';
  final StreamController _streamController = StreamController<Duration>();
  late final Stream<Duration> _stream = _streamController.stream as Stream<Duration> ;
  late final StreamSubscription _streamSubscription;
  Duration? totalDuration = const Duration(minutes:0, seconds: 0);

  @override
  void initState() {
    isSongStarted = true;
    context.read<AudioPlayerBloc>().add(PlayerPlaying());
    _animationController = AnimationController(vsync: this,duration: Duration(seconds: 0),);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _listenToCurrentPosition();
    });
    super.initState();
  }

  void _listenToCurrentPosition() {
   _streamSubscription = player.positionStream.listen((d) {
     _streamController.sink.add(d);
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _streamSubscription.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.whiteBg,
        body: SingleChildScrollView(
          child: BlocBuilder<AudioPlayerBloc,AudioPlayerState>(
            bloc: context.read<AudioPlayerBloc>(),
            builder: (context, state)
               {
                 debugPrint('songSet to ${state.currentSong?.songFile}, ${state.status}');
                 if(state.status != AudioPlayerStatus.failure && state.currentSong!=null)
                   {
                     List<String>? splitDuration = state.currentSong?.audioDuration.split(':');

                     return Container(
                       margin: const EdgeInsets.only(top: 20),
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               IconButton(onPressed: (){
                                 Navigator.pop(context);
                               }, icon: Icon(Icons.arrow_back_ios_new)),
                               SizedBox(width: MediaQuery.of(context).size.width*0.19,),
                               Center(
                                 child: Text('Now playing',style: TextStyle(
                                     color: CustomColors.greyText,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 20
                                 ),),
                               ),
                             ],
                           ),
                           const SizedBox(height: 15,),
                           Card(
                             color: CustomColors.whiteBg,
                             shadowColor: Colors.grey,
                             elevation: 4,
                             clipBehavior: Clip.hardEdge,
                             shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(100)
                             ),
                             child: Padding(
                               padding: const EdgeInsets.all(5.0),
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(100),
                                 child: Image.network(state.currentSong?.albumCoverImage ?? "https://i.tribune.com.pk/media/images/647803-music-1387469249/647803-music-1387469249.jpg",
                                   height: MediaQuery.of(context).size.width*0.5,
                                   width: MediaQuery.of(context).size.width*0.5,
                                 ),
                               ),
                             ),
                           ),
                           const SizedBox(height: 25,),
                           Text(state.currentSong?.albumName??"",style: const TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 25
                           ),),
                           Text(state.currentSong?.singerName??"",style: TextStyle(
                               fontWeight: FontWeight.bold,
                               color: CustomColors.greyText,
                               fontSize: 16
                           ),),
                           const SizedBox(height: 20,),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               customShadowBox(
                                   Transform(
                                     alignment: Alignment.center,
                                     transform: Matrix4.rotationY(math.pi),
                                     child: IconButton(icon: Icon(Icons.forward_10_outlined,
                                       color: CustomColors.darkBlue,),
                                       onPressed: () async {
                                       if(player.playing == true)
                                       {
                                         Duration tempDuration = player.position;
                                         if(tempDuration - const Duration(seconds: 10)!= const Duration(seconds: 0))
                                         {
                                           await player.seek(tempDuration - const Duration(seconds: 10));
                                         }
                                       }
                                       },),
                                   )),
                               SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                               customShadowBox(
                                 Row(
                                   children: [
                                     Visibility(
                                         visible: state.status == AudioPlayerStatus.initial,
                                         child: SizedBox(
                                           height: 40,
                                           width: 40,
                                           child: Padding(
                                             padding: const EdgeInsets.all(5.0),
                                             child: CircularProgressIndicator(color: CustomColors.darkBlue,),
                                           ),
                                         )
                                     ),
                                     Visibility(
                                       visible: state.status!=AudioPlayerStatus.initial &&  state.status == AudioPlayerStatus.paused || state.status == AudioPlayerStatus.stopped,
                                       child: IconButton(
                                         icon:
                                         Icon(Icons.play_arrow, color: CustomColors.darkBlue),
                                         onPressed: (){
                                           context.read<AudioPlayerBloc>().add(PlayerResumed());
                                           isSongPlaying = !isSongPlaying;
                                           if(mounted)
                                           {
                                             _animationController.forward();
                                             setState(() {
                                             });
                                           }
                                         },),
                                     ),
                                     Visibility(
                                       visible: state.status!=AudioPlayerStatus.initial && state.status == AudioPlayerStatus.playing,
                                       child: IconButton(
                                         icon:
                                         Icon(Icons.pause, color: CustomColors.darkBlue),
                                         onPressed: (){
                                           context.read<AudioPlayerBloc>().add(PlayerPaused());
                                           isSongPlaying = !isSongPlaying;
                                           _animationController.stop();
                                           if(mounted)
                                           {
                                             setState(() {
                                             });
                                           }
                                         },),
                                     ),
                                   ],
                                 ),),
                               SizedBox(width: MediaQuery.of(context).size.width*0.03,),
                               Visibility(
                                 visible: state.status!=AudioPlayerStatus.initial && state.status != AudioPlayerStatus.stopped,
                                 child: customShadowBox(
                                   IconButton(
                                     icon:
                                     Icon(Icons.stop, color: CustomColors.darkBlue),
                                     onPressed: (){
                                       context.read<AudioPlayerBloc>().add(PlayerStopped());
                                       //PlayerMethods.stopMusic();
                                       isSongPlaying = false;
                                       _animationController.reset();
                                       if(mounted)
                                       {
                                         setState(() {
                                         });
                                       }
                                     },),
                                 ),
                               ),
                               state.status != AudioPlayerStatus.stopped ?
                               SizedBox(width: MediaQuery.of(context).size.width*0.03,) :
                               SizedBox(width: 0,),
                               customShadowBox(
                                   IconButton(icon: Icon(Icons.forward_10_outlined,
                                       color: CustomColors.darkBlue),
                                     onPressed: () async{
                                     if(player.playing == true)
                                       {
                                         Duration tempDuration = player.position;
                                         await player.seek(tempDuration+const Duration(seconds: 10));
                                       }
                                     },))
                             ],
                           ),
                           const SizedBox(height: 20,),
                           //AudioWaveFormWidget(),
                           StreamBuilder<Duration?>(
                               stream: _stream,
                               initialData: const Duration(minutes: 0,seconds: 0),
                               builder: (BuildContext context, AsyncSnapshot<Duration?> snapshot){
                                 maxduration = "${snapshot.data?.inMinutes.remainder(60)}:${(snapshot.data?.inSeconds.remainder(60))}";
                                 final durationState = snapshot.data;
                                 final progress = durationState ?? Duration.zero;
                                 // print('player.duration ${ player.duration}');
                                 // final total = playingSongDuration ?? Duration.zero;
                                 final total = Duration(minutes: int.parse(splitDuration![0]),seconds: int.parse(splitDuration[1]));
                                 // print('stream-builder-$progress-$total');
                                 return Padding(
                                   padding: const EdgeInsets.all(20.0),
                                   child: ProgressBar(
                                     baseBarColor: CustomColors.greyText,
                                     progressBarColor: CustomColors.darkBlue,
                                     thumbColor: CustomColors.darkBlue,
                                     progress: progress,
                                     total: total,
                                     onSeek: (duration) {
                                       player.seek(duration);
                                     },
                                   ),
                                 );
                               }),
                         ],
                       ),
                     );
                   }
                 else
                   {
                     return SizedBox(
                       height: MediaQuery.of(context).size.height,
                       child: const Center(child: Text('Unable to play audio')),
                     );
                   }
               }
          ),
          ),
        ),
      );
  }


  Widget customShadowBox(Widget child){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white)),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.hardEdge,
        color: CustomColors.whiteBg,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
    );
  }
}
