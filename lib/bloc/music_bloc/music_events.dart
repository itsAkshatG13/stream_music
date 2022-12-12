part of 'music_bloc.dart';

abstract class MusicEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class MusicDataFetched extends MusicEvents {}
