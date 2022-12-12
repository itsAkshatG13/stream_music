class AudioModel {
  final String albumCoverImage;
  final String albumName;
  final String singerName;
  final String audioDuration;
  final String songFile;
  final String id;
  late bool isCurrentlyPlaying;

  AudioModel({
    this.albumCoverImage='',
    this.albumName='',
    this.audioDuration='',
    this.singerName='',
    this.songFile='',
    this.id ='',
    this.isCurrentlyPlaying = false,
  });

  static AudioModel fromJson(var json) {
    return  AudioModel(
        albumCoverImage: json["albumCoverImage"],
        albumName: json["albumName"],
        singerName: json["singerName"],
        audioDuration: json["audioDuration"],
        songFile: json["songFile"],
        id: json["id"],
        isCurrentlyPlaying: false
    );
  }

  // @override
  // List<Object> get props => [albumName,albumCoverImage,singerName,songFile,audioDuration];
}

