import 'package:calculator/pages/vault_filter_page.dart';
import 'package:collection/collection.dart';

import 'media_item.dart';

abstract class VaultFilter implements Comparable<MediaItem> {
  String get name;

  bool appliesTo(MediaItem mediaItem);
}

abstract class ExtendedVaultFilter extends VaultFilter {
  bool pictures = true;
  bool animatedPictures = true;
  bool movies = true;
  int minNumberOfStars = 1;
}

class UnRatedOrUntagged extends VaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "TO RATE OR TAG";
}

class FirstSeen extends ExtendedVaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "FIRST SEEN";
}

class LastSeen extends ExtendedVaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "LAST SEEN";
}

class RandomOrder extends ExtendedVaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "RANDOM ORDER";
}

class PotentialDoubles extends VaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "POTENTIAL DOUBLES";
}

class BiggestToSmallest extends ExtendedVaultFilter {
  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "BIGGEST";
}

/// A [ExtendedVaultFilter] that holds the values for the [VaultFilterPage] Form
class FormVaultFilter extends ExtendedVaultFilter {
  VaultFilter type = VaultFilters().first;

  @override
  bool appliesTo(MediaItem mediaItem) {
    // TODO: implement appliesTo
    throw UnimplementedError();
  }

  @override
  int compareTo(MediaItem other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  @override
  String get name => "FormVaultFilter";
}

class VaultFilters extends DelegatingList<VaultFilter> {
  static final VaultFilters _singleton = VaultFilters._();

  factory VaultFilters() {
    return _singleton;
  }

  VaultFilters._() : super(_createVaultFilters);

  static List<VaultFilter> get _createVaultFilters => [
        UnRatedOrUntagged(),
        FirstSeen(),
        LastSeen(),
        RandomOrder(),
        PotentialDoubles(),
        BiggestToSmallest()
      ];
}
