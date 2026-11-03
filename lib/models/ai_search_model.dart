class AiSearchCardModel {
  final String tag;
  final String title;
  final String price;
  final String meta;
  final String type; // 'market', 'bike', 'service', 'roommate', 'commute'
  final String id;
  final Map<String, dynamic>? raw;

  AiSearchCardModel({
    required this.tag,
    required this.title,
    required this.price,
    required this.meta,
    required this.type,
    required this.id,
    this.raw,
  });

  factory AiSearchCardModel.fromJson(Map<String, dynamic> json) {
    return AiSearchCardModel(
      tag: json['tag']?.toString() ?? 'Market',
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      meta: json['meta']?.toString() ?? '',
      type: json['type']?.toString() ?? 'market',
      id: json['id']?.toString() ?? '',
      raw: json['raw'] is Map ? Map<String, dynamic>.from(json['raw'] as Map) : null,
    );
  }
}

class AiSearchResultModel {
  final String reply;
  final String understood;
  final String campusChecked;
  final List<String> searchedTags;
  final List<AiSearchCardModel> cards;
  final List<String> chips;
  final bool noMatch;

  AiSearchResultModel({
    required this.reply,
    required this.understood,
    required this.campusChecked,
    this.searchedTags = const [],
    this.cards = const [],
    this.chips = const [],
    this.noMatch = false,
  });

  factory AiSearchResultModel.fromJson(Map<String, dynamic> json) {
    List<AiSearchCardModel> parsedCards = [];
    if (json['cards'] is List) {
      parsedCards = (json['cards'] as List)
          .map((c) => AiSearchCardModel.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList();
    }

    List<String> parsedTags = [];
    if (json['searchedTags'] is List) {
      parsedTags = (json['searchedTags'] as List).map((t) => t.toString()).toList();
    }

    List<String> parsedChips = [];
    if (json['chips'] is List) {
      parsedChips = (json['chips'] as List).map((c) => c.toString()).toList();
    }

    return AiSearchResultModel(
      reply: json['reply']?.toString() ?? '',
      understood: json['understood']?.toString() ?? 'Understood your request',
      campusChecked: json['campusChecked']?.toString() ?? 'Checked campus listings',
      searchedTags: parsedTags,
      cards: parsedCards,
      chips: parsedChips,
      noMatch: json['noMatch'] == true || parsedCards.isEmpty,
    );
  }
}

