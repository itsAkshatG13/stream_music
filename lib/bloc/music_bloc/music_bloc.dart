import 'dart:async';
import 'package:audiobook_demo/utilities/firebase_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:audiobook_demo/models/song.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:stream_transform/stream_transform.dart';
part 'music_events.dart';
part 'music_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class MusicBloc extends Bloc<MusicEvents, MusicState> {
  MusicBloc() : super(const MusicState()) {
    on<MusicDataFetched>(
      _onMusicFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _onMusicFetched(
      MusicDataFetched event,
      Emitter<MusicState> emit,
      ) async {
    try {
      if (state.status != MusicStatus.initial) {
        final List<AudioModel> songs = await _fetchMusicData();
        return emit(state.copyWith(
          status: MusicStatus.success,
          songs$: songs,
        ));
      }
      final songs = await _fetchMusicData(state.songs$.length);
      emit(
        state.copyWith(
          status: MusicStatus.success,
          songs$: List.of(state.songs$)..addAll(songs),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MusicStatus.failure));
    }
  }

  Future<List<AudioModel>> _fetchMusicData([int startIndex = 0]) async
  {
    debugPrint('In fetch music');
    FirebaseClass firebaseClass = FirebaseClass();
    QuerySnapshot? querySnapshot = await firebaseClass.getFirestoreData(collectionId: 'songs');
    List<AudioModel> tempSongs = [] ;
    if(querySnapshot!= null && querySnapshot.docs.isNotEmpty) {
      for(var document in querySnapshot.docs) {
        AudioModel tempModel = AudioModel.fromJson(document);
        tempSongs.add(tempModel);
      }
      return tempSongs;
    }
    return [];
  }
}
