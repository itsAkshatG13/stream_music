part of 'player_bloc.dart';

enum AudioPlayerStatus {initial, playing, paused, stopped, failure}

class AudioPlayerState extends Equatable {
   AudioPlayerState({
     this.status = AudioPlayerStatus.initial,
     this.currentSong,
  });

  final AudioPlayerStatus status;
  late AudioModel? currentSong;

  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    AudioModel? currentSong,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
    );
  }

  @override
  String toString() {
    return '''PLAYER_STATE { status: $status, playing: ${currentSong?.albumName} }''';
  }

  @override
  List<Object> get props => [status, currentSong?? AudioModel()];
}
