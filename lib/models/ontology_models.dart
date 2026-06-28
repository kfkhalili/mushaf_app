import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../constants.dart';
import '../utils/parsing_helpers.dart';
import '../utils/helpers.dart';

// --- Ontology Models ---

@immutable
class Topic extends Equatable {
  const Topic({
    required this.topicId,
    this.name,
    required this.arabicName,
    this.parentId,
    this.thematicParentId,
    this.ontologyParentId,
    this.description,
    this.wikiLink,
    required this.isThematic,
    required this.isOntology,
  });

  final int topicId;
  final String? name;
  final String arabicName;
  final int? parentId;
  final int? thematicParentId;
  final int? ontologyParentId;
  final String? description;
  final String? wikiLink;
  final bool isThematic;
  final bool isOntology;

  factory Topic.fromMap(Map<String, dynamic> map) {
    // Handle null arabic_name - use empty string (no fallback to English)
    // WHY: User requested Arabic-only display, so don't fall back to English name
    final arabicNameRaw = map[DbConstants.arabicNameCol];
    final String arabicName =
        arabicNameRaw != null && arabicNameRaw.toString().isNotEmpty
        ? arabicNameRaw
              .toString()
              .trim() // Trim leading/trailing whitespace
        : ''; // Use empty string instead of English name fallback

    return Topic(
      topicId: parseInt(map[DbConstants.topicIdCol]),
      name: map[DbConstants.nameCol] as String?,
      arabicName: arabicName,
      parentId: map[DbConstants.parentIdCol] as int?,
      thematicParentId: map[DbConstants.thematicParentIdCol] as int?,
      ontologyParentId: map[DbConstants.ontologyParentIdCol] as int?,
      description: map[DbConstants.descriptionCol] as String?,
      wikiLink: map[DbConstants.wikiLinkCol] as String?,
      isThematic: (map[DbConstants.thematicCol] as int? ?? 0) == 1,
      isOntology: (map[DbConstants.ontologyCol] as int? ?? 0) == 1,
    );
  }

  // WHY: Topic is an entity keyed by its primary key — two rows with the same
  // topicId are the same topic. Identity is intentionally topicId only, not a
  // value comparison of every field.
  @override
  List<Object?> get props => [topicId];
}

@immutable
class VerseReference extends Equatable {
  const VerseReference({required this.surahNumber, required this.ayahNumber});

  final int surahNumber;
  final int ayahNumber;

  // Helper for generating ayah key (matches existing pattern)
  String get ayahKey => generateAyahKey(surahNumber, ayahNumber);

  factory VerseReference.fromMap(Map<String, dynamic> map) {
    return VerseReference(
      surahNumber: parseInt(map[DbConstants.surahNumberCol]),
      ayahNumber: parseInt(map[DbConstants.ayahNumberCol]),
    );
  }

  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}
