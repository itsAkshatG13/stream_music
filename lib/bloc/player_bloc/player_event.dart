part of 'player_bloc.dart';

abstract class AudioPlayerEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class PlayerPlaying extends AudioPlayerEvents{}
class PlayerPaused extends AudioPlayerEvents{}
class PlayerStopped extends AudioPlayerEvents{}
class PlayerResumed extends AudioPlayerEvents{}
