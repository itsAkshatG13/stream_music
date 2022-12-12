import 'package:audiobook_demo/bloc/music_bloc/music_bloc.dart';
import 'package:audiobook_demo/bloc/player_bloc/player_bloc.dart';
import 'package:audiobook_demo/main.dart';
import 'package:audiobook_demo/models/song.dart';
import 'package:audiobook_demo/styles/colors.dart';
import 'package:audiobook_demo/views/nav_bar_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  ScrollController scrollController = ScrollController();

  final AudioPlayerBloc _audioPlayerBloc = AudioPlayerBloc();


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
          backgroundColor: CustomColors.whiteBg,
          body: SingleChildScrollView(
            controller: scrollController,
            child: BlocBuilder<MusicBloc,MusicState>(

              bloc:  context.read<MusicBloc>(),
              builder: (context,state)
              {
                print('musicbloc_builder');
                switch(state.status) {
                  case MusicStatus.failure :
                    return const Center(child: Text('Failed to fetch music'));
                  case MusicStatus.success :
                    if (state.songs$.isEmpty) {
                      return const Center(child: Text('No music found'));
                    }
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " Popular",
                            style: TextStyle(color: CustomColors.greyText,fontSize: 20,fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              popularCardWidget(audioModel: state.songs$[0], followerCount: '751,475',context: context),
                              popularCardWidget(audioModel: state.songs$[3],followerCount: '482,948',context: context)
                            ],
                          ),
                          const SizedBox(height: 30,),
                          Text(
                            " Trending Albums",
                            style: TextStyle(color: CustomColors.greyText,fontSize: 20,fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10,),
                          trendingWidget(songList: state.songs$),
                          const SizedBox(height: 10,),

                        ],
                      ),
                    );

                  default:
                    return SizedBox(
                        height: screenHeight,
                        child: Center(child: CircularProgressIndicator(
                          color: CustomColors.darkBlue,
                        )));
                }
              },
            ),
          ),
        ));
  }

  Widget popularCardWidget({required AudioModel audioModel , required String followerCount, required BuildContext context,})
  {
    return InkWell(
     onTap: (){
       context.read<AudioPlayerBloc>().state.currentSong = audioModel;
       playingSongFile = audioModel;
       Navigator.push(context,MaterialPageRoute(builder: (context)=>
           NavigationBarHomePage(selectedIndex:  1,
             playMusicModel: audioModel,
           )),);
     },
      child: Card(
        elevation: 10,
        clipBehavior: Clip.hardEdge,
        color: CustomColors.whiteBg,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: screenWidth*0.4,
          height: 220,
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(audioModel.albumCoverImage,
                  height: 100,width: 100,),
              ),
              const SizedBox(height: 15,),
              Text(audioModel.albumName,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              const SizedBox(height: 5,),
              Text('$followerCount followers',style: TextStyle(color: CustomColors.greyText,fontWeight: FontWeight.w600),),
            ],
          ),
        ),
      ),
    );
  }

  Widget trendingWidget({required List<AudioModel> songList})
  {
    return Card(
      elevation: 10,
      clipBehavior: Clip.hardEdge,
      color: CustomColors.whiteBg,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          padding: const EdgeInsets.all(15),
          child: ListView.builder(
            controller: scrollController,
            itemBuilder: (context,index,){
              return albumWidget(
                  context,
                  index,
                  songList[index]);
            },
            itemCount: songList.length,
            shrinkWrap: true,)
      ),
    );
  }

  Widget albumWidget(BuildContext context , int index, AudioModel audioModel,)
  {
    return InkWell(
      onTap: (){
        context.read<AudioPlayerBloc>().state.currentSong = audioModel;
        print('Set-song ${context.read<AudioPlayerBloc>().state.currentSong!.albumName}');
        playingSongFile = audioModel;
        for(int x=0; x<context.read<MusicBloc>().state.songs$.length; x++)
          {
            if(context.read<MusicBloc>().state.songs$[x].songFile != audioModel.songFile)
              {
                context.read<MusicBloc>().state.songs$[x].isCurrentlyPlaying = false;
              }
          }
        context.read<MusicBloc>().state.copyWith(
          status: MusicStatus.success,
          songs$: context.read<MusicBloc>().state.songs$
        );

        Navigator.push(context,MaterialPageRoute(builder: (context)=>
            NavigationBarHomePage(selectedIndex:  1,
              playMusicModel: audioModel,
        )),);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5,bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            audioModel.isCurrentlyPlaying ?
            const Icon(Icons.play_arrow,size: 22,)
                :
            Text('${index+1}   '),
            SizedBox(width: screenWidth*0.02,),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(audioModel.albumCoverImage,
                height: 60,
                width: 60,
              ),
            ),
            SizedBox(width: screenWidth*0.02,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth*0.3,
                  child: Text(audioModel.albumName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                  softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5,),
                Text(audioModel.singerName,style: const TextStyle(color: Color(0xffC5C6CD),
                    fontWeight: FontWeight.bold,fontSize: 15),)
              ],
            ),
            const Spacer(),
            Text(audioModel.audioDuration,style: const TextStyle(color: Color(0xffC5C6CD),fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}
