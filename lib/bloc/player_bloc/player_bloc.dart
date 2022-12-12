import 'dart:async';
import 'package:audiobook_demo/main.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:audiobook_demo/models/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:stream_transform/stream_transform.dart';
part 'player_event.dart';
part 'player_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AudioPlayerBloc extends Bloc<AudioPlayerEvents, AudioPlayerState> {
  AudioPlayerBloc() : super( AudioPlayerState()) {
    on<PlayerPlaying>(
      playMusic,
      transformer: throttleDroppable(throttleDuration),
    );
    on<PlayerPaused>(
      pauseMusic,
      transformer: throttleDroppable(throttleDuration),
    );
    on<PlayerStopped>(
      stopMusic,
      transformer: throttleDroppable(throttleDuration),
    );
    on<PlayerResumed>(
      resumeMusic,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  void playMusic(
      PlayerPlaying event,
      Emitter<AudioPlayerState> emit,
      ) async {
    try {
      print('Current-song ${state.currentSong!.albumName}');
       // state.currentSong =  state.currentSong ?? playingSongFile;
      emit(
          state.copyWith(
          status : AudioPlayerStatus.initial,
      ));

      if(state.currentSong?.isCurrentlyPlaying == false)
        {
          bool? _isSongStarted = await _playMusic(song: state.currentSong ?? AudioModel());
          if(_isSongStarted == true)
            {
              state.currentSong?.isCurrentlyPlaying = true;
              Future.delayed(Duration(milliseconds: 200));
              return emit(
                  state.copyWith(
                    status: AudioPlayerStatus.playing,
                    currentSong: state.currentSong,
                  ));
            }
        }
      else{
        return emit (
          state.copyWith(
            status: AudioPlayerStatus.playing,
            currentSong: state.currentSong
          )
        );
      }
    } catch (e) {
      print('Exception(playSong) $e');
      emit(state.copyWith(status: AudioPlayerStatus.failure));
    }
  }

  Future<bool?> _playMusic({required AudioModel song,}) async {
    try
    {
      if(player.playing == true)
      {
        player.stop();
      }
      print('hi debug');

      player.setAudioSource(AudioSource.uri(
        Uri.parse(song.songFile),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: song.id,
          artist: song.singerName,
          title: song.albumName,
          artUri: Uri.parse(song.albumCoverImage),
        ),
      ));
      // playingSongDuration = await player.setUrl(song.songFile);
      player.play();

      print('AudioPlayer-event-music started');
      if(player.playing == true)
      {
        debugPrint('State playing');
        return true;
      }
      else
      {
        debugPrint('State not playing');
        return false;
      }
    }
    catch(e)
    {
      debugPrint('Exception_music_player $e');
    }
    return null;
  }

  void pauseMusic(
      PlayerPaused event,
      Emitter<AudioPlayerState> emit,) async
  {
    await player.pause();
    print('AudioPlayer-event-music paused');
    if(player.playing != true)
    {
      emit(
        state.copyWith(
            status: AudioPlayerStatus.paused ,
            currentSong: state.currentSong)
      );
    }
    else
    {
      emit(
        state.copyWith(status: AudioPlayerStatus.failure)
      );
    }
  }

  void resumeMusic(
      PlayerResumed event,
      Emitter<AudioPlayerState> emit
      ) async
  {
    print('AudioPlayer-event-music resume');
    emit (
        state.copyWith(status: AudioPlayerStatus.playing,
            currentSong: state.currentSong));
    await player.play();
  }

  void stopMusic(
      PlayerStopped event,
      Emitter<AudioPlayerState> emit) async
  {
    await player.stop();
    await player.seek(Duration(seconds: 0));
    print('AudioPlayer-event-music stop');
    state.currentSong?.isCurrentlyPlaying = false;
    emit(
      state.copyWith(status: AudioPlayerStatus.stopped,)
    );
  }

  // void _updateAlbums(List<Song> songs) {
  //   Map<int, Album> _albumsMap = {};
  //   for (Song song in songs) {
  //     if (_albumsMap[song.albumId] == null) {
  //       _albumsMap[song.albumId] = Album.fromSong(song);
  //     }
  //   }
  //   final List<Album> _albums = _albumsMap.values.toList();
  //   _albums$.add(_albums);
  // }
  //
  // void playNextSong() {
  //   if (_playerState$.value.key == PlayerState.stopped) {
  //     return;
  //   }
  //   final Song _currentSong = _playerState$.value.value;
  //   final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
  //   final List<Song> _playlist =
  //   _isShuffle ? _playlist$.value.value : _playlist$.value.key;
  //   int _index = _playlist.indexOf(_currentSong);
  //   if (_index == _playlist.length - 1) {
  //     _index = 0;
  //   } else {
  //     _index++;
  //   }
  //   stopMusic();
  //   playMusic(_playlist[_index]);
  // }
  //
  // void playPreviousSong() {
  //   if (_playerState$.value.key == PlayerState.stopped) {
  //     return;
  //   }
  //   final Song _currentSong = _playerState$.value.value;
  //   final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
  //   final List<Song> _playlist =
  //   _isShuffle ? _playlist$.value.value : _playlist$.value.key;
  //   int _index = _playlist.indexOf(_currentSong);
  //   if (_index == 0) {
  //     _index = _playlist.length - 1;
  //   } else {
  //     _index--;
  //   }
  //   stopMusic();
  //   playMusic(_playlist[_index]);
  // }
}
