class RideModel {
  final String id;
  final String? campusId;
  final String? universityId;
  final String organizerName;
  final bool organizerVerified;
  final String fromLocation;
  final String toLocation;
  final String departureTime;
  final String departureDate;
  final String vehicleType; // 'rickshaw' | 'bike' | 'car'
  final int totalCost;
  final int pricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final String pickupPoint;
  final String notes;
  final String status; // 'active' | 'completed' | 'cancelled'
  final String? createdAt;

  RideModel({
    required this.id,
    this.campusId,
    this.universityId,
    required this.organizerName,
    this.organizerVerified = true,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    this.departureDate = 'Today',
    this.vehicleType = 'rickshaw',
    required this.totalCost,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.availableSeats,
    this.pickupPoint = 'Main road stop',
    this.notes = '',
    this.status = 'active',
    this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id']?.toString() ?? 'r_${DateTime.now().millisecondsSinceEpoch}',
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
      universityId: json['university_id']?.toString() ?? json['universityId']?.toString(),
      organizerName: json['organizer_name']?.toString() ?? json['organizerName']?.toString() ?? 'Student Driver',
      organizerVerified: json['organizer_verified'] == true || json['organizerVerified'] == true,
      fromLocation: json['from_location']?.toString() ?? json['fromLocation']?.toString() ?? 'Campus Area',
      toLocation: json['to_location']?.toString() ?? json['toLocation']?.toString() ?? 'University',
      departureTime: json['departure_time']?.toString() ?? json['departureTime']?.toString() ?? '08:00 AM',
      departureDate: json['departure_date']?.toString() ?? json['departureDate']?.toString() ?? 'Today',
      vehicleType: (json['vehicle_type']?.toString() ?? json['vehicleType']?.toString() ?? 'rickshaw').toLowerCase(),
      totalCost: (json['total_cost'] ?? json['totalCost'] ?? 200) is int
          ? (json['total_cost'] ?? json['totalCost'] ?? 200)
          : int.tryParse(json['total_cost']?.toString() ?? json['totalCost']?.toString() ?? '200') ?? 200,
      pricePerSeat: (json['price_per_seat'] ?? json['pricePerSeat'] ?? 50) is int
          ? (json['price_per_seat'] ?? json['pricePerSeat'] ?? 50)
          : int.tryParse(json['price_per_seat']?.toString() ?? json['pricePerSeat']?.toString() ?? '50') ?? 50,
      totalSeats: (json['total_seats'] ?? json['totalSeats'] ?? 4) is int
          ? (json['total_seats'] ?? json['totalSeats'] ?? 4)
          : int.tryParse(json['total_seats']?.toString() ?? json['totalSeats']?.toString() ?? '4') ?? 4,
      availableSeats: (json['available_seats'] ?? json['availableSeats'] ?? 1) is int
          ? (json['available_seats'] ?? json['availableSeats'] ?? 1)
          : int.tryParse(json['available_seats']?.toString() ?? json['availableSeats']?.toString() ?? '1') ?? 1,
      pickupPoint: json['pickup_point']?.toString() ?? json['pickupPoint']?.toString() ?? 'Main road stop',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'university_id': universityId,
      'organizer_name': organizerName,
      'organizer_verified': organizerVerified,
      'from_location': fromLocation,
      'to_location': toLocation,
      'departure_time': departureTime,
      'departure_date': departureDate,
      'vehicle_type': vehicleType,
      'total_cost': totalCost,
      'price_per_seat': pricePerSeat,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'pickup_point': pickupPoint,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
    };
  }

  RideModel copyWith({
    String? id,
    String? campusId,
    String? universityId,
    String? organizerName,
    bool? organizerVerified,
    String? fromLocation,
    String? toLocation,
    String? departureTime,
    String? departureDate,
    String? vehicleType,
    int? totalCost,
    int? pricePerSeat,
    int? totalSeats,
    int? availableSeats,
    String? pickupPoint,
    String? notes,
    String? status,
    String? createdAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      campusId: campusId ?? this.campusId,
      universityId: universityId ?? this.universityId,
      organizerName: organizerName ?? this.organizerName,
      organizerVerified: organizerVerified ?? this.organizerVerified,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      departureTime: departureTime ?? this.departureTime,
      departureDate: departureDate ?? this.departureDate,
      vehicleType: vehicleType ?? this.vehicleType,
      totalCost: totalCost ?? this.totalCost,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RideBookingModel {
  final String id;
  final String rideId;
  final String riderName;
  final String route;
  final String departureTime;
  final int pricePerSeat;
  final String vehicleType;
  final String organizerName;
  final String date;
  final String status;

  RideBookingModel({
    required this.id,
    required this.rideId,
    required this.riderName,
    required this.route,
    required this.departureTime,
    required this.pricePerSeat,
    required this.vehicleType,
    required this.organizerName,
    required this.date,
    this.status = 'confirmed',
  });

  factory RideBookingModel.fromJson(Map<String, dynamic> json) {
    return RideBookingModel(
      id: json['id']?.toString() ?? 'bk_${DateTime.now().millisecondsSinceEpoch}',
      rideId: json['ride_id']?.toString() ?? json['rideId']?.toString() ?? '',
      riderName: json['rider_name']?.toString() ?? json['riderName']?.toString() ?? 'Student',
      route: json['route']?.toString() ?? 'Campus Commute Route',
      departureTime: json['departure_time']?.toString() ?? json['departureTime']?.toString() ?? 'Scheduled',
      pricePerSeat: (json['price_per_seat'] ?? json['pricePerSeat'] ?? 50) is int
          ? (json['price_per_seat'] ?? json['pricePerSeat'] ?? 50)
          : int.tryParse(json['price_per_seat']?.toString() ?? json['pricePerSeat']?.toString() ?? '50') ?? 50,
      vehicleType: json['vehicle_type']?.toString() ?? json['vehicleType']?.toString() ?? 'rickshaw',
      organizerName: json['organizer_name']?.toString() ?? json['organizerName']?.toString() ?? 'Student Driver',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
      status: json['status']?.toString() ?? 'confirmed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'rider_name': riderName,
      'route': route,
      'departure_time': departureTime,
      'price_per_seat': pricePerSeat,
      'vehicle_type': vehicleType,
      'organizer_name': organizerName,
      'date': date,
      'status': status,
    };
  }
}

class BikeModel {
  final String id;
  final String model;
  final int dailyRate;
  final int depositAmount;
  final String location;
  final String condition;
  final String availableDate;
  final String availableTime;
  final String rules;
  final bool isAvailable;
  final String? campusId;

  BikeModel({
    required this.id,
    required this.model,
    required this.dailyRate,
    this.depositAmount = 500,
    required this.location,
    this.condition = 'Good condition',
    this.availableDate = 'Today',
    this.availableTime = '8 AM – 6 PM',
    this.rules = 'Valid student card required for checkout.',
    this.isAvailable = true,
    this.campusId,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id']?.toString() ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
      model: json['model']?.toString() ?? 'Campus Bicycle',
      dailyRate: (json['daily_rate'] ?? json['dailyRate'] ?? 150) is int
          ? (json['daily_rate'] ?? json['dailyRate'] ?? 150)
          : int.tryParse(json['daily_rate']?.toString() ?? json['dailyRate']?.toString() ?? '150') ?? 150,
      depositAmount: (json['deposit_amount'] ?? json['depositAmount'] ?? 500) is int
          ? (json['deposit_amount'] ?? json['depositAmount'] ?? 500)
          : int.tryParse(json['deposit_amount']?.toString() ?? json['depositAmount']?.toString() ?? '500') ?? 500,
      location: json['location']?.toString() ?? 'Library Bike Stand',
      condition: json['condition']?.toString() ?? 'Good condition',
      availableDate: json['available_date']?.toString() ?? json['availableDate']?.toString() ?? 'Today',
      availableTime: json['available_time']?.toString() ?? json['availableTime']?.toString() ?? '8 AM – 6 PM',
      rules: json['rules']?.toString() ?? 'Valid student ID required.',
      isAvailable: json['is_available'] == true || json['isAvailable'] == true,
      campusId: json['campus_id']?.toString() ?? json['campusId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'daily_rate': dailyRate,
      'deposit_amount': depositAmount,
      'location': location,
      'condition': condition,
      'available_date': availableDate,
      'available_time': availableTime,
      'rules': rules,
      'is_available': isAvailable,
      'campus_id': campusId,
    };
  }
}
