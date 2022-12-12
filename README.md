
# Audiobook_Demo

# Contents

* [Pubs Used](#pubs-used)
* [Directory Structure](#directory-structure)

## Pubs Used
  
  just_audio: ^0.9.27

  just_audio_background: ^0.0.1-beta.7

  http: ^0.13.4

  firebase_core: ^1.18.0

  cloud_firestore: ^3.1.18

  flutter_bloc: ^8.0.1

  equatable: ^2.0.3

  bloc_concurrency: ^0.2.0

  stream_transform: ^2.0.0

  audio_video_progress_bar: ^0.10.0

## Directory Structure
    lib
    |-- bloc
    |    |-- music_bloc
    |            |-- music_bloc.dart
    |            |-- music_state.dart
    |            |-- music_event.dart
    |     |-- player_bloc
    |            |-- player_bloc.dart
    |            |-- player_state.dart
    |            |-- player_event.dart
    |-- models
    |    |-- song_model.dart
    |-- views
    |    |-- homepage.dart
    |    |-- player_screen.dart
    |    |-- navbar_home.dart
    |-- utilities
    |    |-- firebase_utils.dart
    |    |-- player_methods.dart
    |-- styles
    |    |-- colors.dart
    |    |-- icons.dart
