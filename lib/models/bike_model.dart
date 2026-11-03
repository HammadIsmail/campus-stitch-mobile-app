class BikeModel {
  final String id;
  final String? campusId;
  final String? ownerId;
  final String ownerName;
  final String model;
  final double hourlyRate;
  final double dailyRate;
  final String location;
  final String window;
  final String availableFrom;
  final String untilTime;
  final List<String> days;
  final bool helmetIncluded;
  final bool isAvailable;
  final bool isPaused;
  final String? imageUrl;
  final String status;

  BikeModel({
    required this.id,
    this.campusId,
    this.ownerId,
    required this.ownerName,
    required this.model,
    this.hourlyRate = 80.0,
    required this.dailyRate,
    required this.location,
    this.window = 'Today, 4:00 to 9:00 PM',
    this.availableFrom = '4:00 PM',
    this.untilTime = '9:00 PM',
    this.days = const ['M', 'T', 'W', 'T', 'F'],
    this.helmetIncluded = true,
    this.isAvailable = true,
    this.isPaused = false,
    this.imageUrl,
    this.status = 'Available',
  });

  String get rateText => 'Rs ${hourlyRate.toInt()}/hr · Rs ${dailyRate.toInt()}/day';

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    final daily = (json['daily_rate'] != null)
        ? (json['daily_rate'] as num).toDouble()
        : (json['dailyRate'] != null)
            ? (json['dailyRate'] as num).toDouble()
            : 500.0;
    final hourly = (json['hourly_rate'] != null)
        ? (json['hourly_rate'] as num).toDouble()
        : (json['hourlyRate'] != null)
            ? (json['hourlyRate'] as num).toDouble()
            : (daily / 6.0).roundToDouble();

    final isAvail = json['is_available'] == true || json['isAvailable'] == true;

    return BikeModel(
      id: json['id']?.toString() ?? '',
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString(),
      ownerName: json['owner_name']?.toString() ?? json['ownerName']?.toString() ?? 'Student',
      model: json['model']?.toString() ?? 'Bike',
      hourlyRate: hourly,
      dailyRate: daily,
      location: json['location']?.toString() ?? 'Campus Hostel',
      window: json['available_time']?.toString() ?? json['window']?.toString() ?? 'Today, 4:00 to 9:00 PM',
      availableFrom: json['available_from']?.toString() ?? '4:00 PM',
      untilTime: json['until_time']?.toString() ?? '9:00 PM',
      helmetIncluded: json['helmet_included'] == true || json['helmetIncluded'] == true,
      isAvailable: isAvail,
      isPaused: json['is_paused'] == true,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      status: isAvail ? 'Available' : 'Booked',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'campusId': campusId,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'model': model,
    'hourlyRate': hourlyRate,
    'dailyRate': dailyRate,
    'location': location,
    'window': window,
    'availableFrom': availableFrom,
    'untilTime': untilTime,
    'helmetIncluded': helmetIncluded,
    'isAvailable': isAvailable,
    'isPaused': isPaused,
    'imageUrl': imageUrl,
  };
}

class BikeRequestModel {
  final String id;
  final String bikeId;
  final String name;
  final String initial;
  final String bike;
  final String slot;
  final String note;
  final String status;
  final bool isPending;
  final bool isBooked;
  final String? renterId;

  String get renterName => name;
  String get bikeModel => bike;

  BikeRequestModel({
    required this.id,
    required this.bikeId,
    required this.name,
    required this.initial,
    required this.bike,
    required this.slot,
    required this.note,
    required this.status,
    required this.isPending,
    required this.isBooked,
    this.renterId,
  });

  factory BikeRequestModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString() ?? 'Pending';
    final isBooked = statusStr == 'Booked' || statusStr == 'confirmed' || statusStr == 'active';
    final isPending = statusStr == 'Pending' || statusStr == 'pending';

    return BikeRequestModel(
      id: json['id']?.toString() ?? '',
      bikeId: json['bikeId']?.toString() ?? json['bike_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['renter_name']?.toString() ?? 'Student',
      initial: json['initial']?.toString() ??
          ((json['name']?.toString() ?? 'S')[0].toUpperCase()),
      bike: json['bike']?.toString() ?? 'Honda CD 70',
      slot: json['slot']?.toString() ?? 'Today, 4:00 to 7:00 PM',
      note: json['note']?.toString() ?? 'Need it for campus transit.',
      status: isBooked ? 'Booked' : 'Pending',
      isPending: isPending,
      isBooked: isBooked,
      renterId: json['renter_id']?.toString() ?? json['user_id']?.toString() ?? 'u_renter',
    );
  }
}

