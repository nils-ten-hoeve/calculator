import 'package:collection/collection.dart';

/// represents a
/// - [Picture]
/// - a set of [Picture]s
/// - [AnimatedPicture]
/// - [Movie]

class MediaItem {
  final MediaFileType mediaType;
  final List<MediaFile> mediaFiles;
  final DateTime lastViewed;
  ///0=not rated, 1=1 star (worst), 5=5 stars (best)
  final int rating;
  final List<String> tags;

  MediaItem(
      this.mediaType, this.mediaFiles, this.lastViewed, this.rating, this.tags);
}

class MediaFile {
  final String originalName;
  final String uniqueIdentifierName;

  MediaFile(this.originalName, this.uniqueIdentifierName);
}

abstract class MediaFileType {
  final List<String> fileExtensions;

  MediaFileType(this.fileExtensions);

  bool appliesTo(String lowerCaseFileName) {
    for (String fileExtension in fileExtensions) {
      if (lowerCaseFileName.endsWith(fileExtension)) return true;
    }
    return false;
  }
}

class Picture extends MediaFileType {
  static final Picture _singleton = Picture._();

  factory Picture() {
    return _singleton;
  }

  Picture._() : super(['.jpg', '.jpeg', '.png', '.tif', '.tiff', '.bmp']);
}

class AnimatedPicture extends MediaFileType {
  static final AnimatedPicture _singleton = AnimatedPicture._();

  factory AnimatedPicture() {
    return _singleton;
  }

  AnimatedPicture._() : super(['.gif']);
}

class Movie extends MediaFileType {
  static final Movie _singleton = Movie._();

  factory Movie() {
    return _singleton;
  }

  Movie._() : super(['mp4', '.m4p', '.m4v']);
}

class MediaFileTypes extends DelegatingList {
  static final MediaFileTypes _singleton = MediaFileTypes._();

  factory MediaFileTypes() {
    return _singleton;
  }

  MediaFileTypes._() : super(createMediaTypes());

  static List<dynamic> createMediaTypes() =>
      [Picture(), AnimatedPicture(), Movie()];
}
