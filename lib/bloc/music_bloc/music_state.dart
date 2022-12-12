part of 'music_bloc.dart';

enum MusicStatus {initial, success, failure }

class MusicState extends Equatable {
  const MusicState({
    this.status = MusicStatus.initial,
    this.songs$ = const <AudioModel>[],
  });

  final MusicStatus status;
  final List<AudioModel> songs$;

  MusicState copyWith({
    MusicStatus? status,
    List<AudioModel>? songs$,
  }) {
    return MusicState(
      status: status ?? this.status,
      songs$: songs$ ?? this.songs$,
    );
  }

  @override
  String toString() {
    return 'MUSIC_STATE { status: $status, music: ${songs$.length} }';
  }

  @override
  List<Object> get props => [status, songs$];
}
