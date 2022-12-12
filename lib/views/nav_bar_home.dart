import 'package:audiobook_demo/bloc/music_bloc/music_bloc.dart';
import 'package:audiobook_demo/bloc/player_bloc/player_bloc.dart';
import 'package:audiobook_demo/main.dart';
import 'package:audiobook_demo/models/song.dart';
import 'package:audiobook_demo/styles/colors.dart';
import 'package:audiobook_demo/styles/icons.dart';
import 'package:audiobook_demo/views/homepage.dart';
import 'package:audiobook_demo/views/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBarHomePage extends StatefulWidget {
  int? selectedIndex;
  AudioModel? playMusicModel;
  NavigationBarHomePage({Key? key,this.selectedIndex,this.playMusicModel}) : super(key: key);
  @override
  State<NavigationBarHomePage> createState() => _NavigationBarHomePageState();
}

class _NavigationBarHomePageState extends State<NavigationBarHomePage> {
  final _myPage = PageController(initialPage: 0);
  int selectedPage = 0;

  @override
  void initState() {
    if(widget.selectedIndex!=null && widget.playMusicModel!=null)
      {
        selectedPage = widget.selectedIndex!;
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          _myPage.jumpToPage(selectedPage);
        });
      }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.whiteBg,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _myPage,
        children: [
          selectedPage == 0 ? HomePage() : PlayerScreen()
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: selectedPage == 0,
        child: BlocBuilder<AudioPlayerBloc,AudioPlayerState>(
          bloc: context.read<AudioPlayerBloc>(),
          builder: (context, state)
          {
            if(state.currentSong!=null)
              {
                return InkWell(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>
                        NavigationBarHomePage(selectedIndex:  1,
                          playMusicModel: state.currentSong,
                        )),);
                  },
                  child: Container(
                    height: state.status == AudioPlayerStatus.playing ||
                        state.status == AudioPlayerStatus.paused ? 80 : 0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.black),
                      color: Colors.white70
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Visibility(
                        visible: state.status == AudioPlayerStatus.playing ||
                            state.status == AudioPlayerStatus.paused ? true : false,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(state.currentSong?.albumCoverImage ??
                                  "https://i.tribune.com.pk/media/images/647803-music-1387469249/647803-music-1387469249.jpg",
                                height: MediaQuery.of(context).size.width*0.1,
                                width: MediaQuery.of(context).size.width*0.1,
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.5,
                                  child: Text(state.currentSong!.albumName,
                                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.5,
                                  child: Text(state.currentSong!.singerName,
                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey.shade600),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Visibility(
                              visible: state.status == AudioPlayerStatus.paused || state.status == AudioPlayerStatus.stopped,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(100)
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.play_arrow,color: Colors.white,),
                                  onPressed: (){
                                    context.read<AudioPlayerBloc>().add(PlayerResumed());
                                    isSongPlaying = !isSongPlaying;
                                    setState(() {
                                    });
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: state.status == AudioPlayerStatus.playing,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(100)
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.pause,color: Colors.white,),
                                  onPressed: (){
                                    context.read<AudioPlayerBloc>().add(PlayerPaused());
                                    isSongPlaying = !isSongPlaying;
                                    setState(() {
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02,)
                          ],),
                      ),
                    ),
                  ),
                );
              }
            else
            {
              return const SizedBox(height: 0,);
            }
          },
        ),
      ),

    );
  }
}
