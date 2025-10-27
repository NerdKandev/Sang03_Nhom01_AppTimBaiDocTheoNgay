class GlossaryItem {
  final String id;
  final String term;
  final String definition;
  final String? synonyms;
  final String? tags;

  GlossaryItem({
    required this.id,
    required this.term,
    required this.definition,
    this.synonyms,
    this.tags,
  });

  factory GlossaryItem.fromMap(Map<String, dynamic> map) {
    return GlossaryItem(
      id: map['id'] as String,
      term: map['term'] as String,
      definition: map['definition'] as String,
      synonyms: map['synonyms'] as String?,
      tags: map['tags'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'synonyms': synonyms,
      'tags': tags,
    };
  }
}
