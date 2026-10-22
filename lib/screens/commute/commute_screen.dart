import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';

class CommuteRide {
  final String id;
  final String from;
  final String to;
  final String time;
  final int price;
  final int seats;
  final String driverName;
  final String vehicle;
  final String campusId;

  CommuteRide({
    required this.id,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.seats,
    required this.driverName,
    required this.vehicle,
    required this.campusId,
  });
}

class CommuteScreen extends StatefulWidget {
  const CommuteScreen({super.key});

  @override
  State<CommuteScreen> createState() => _CommuteScreenState();
}

class _CommuteScreenState extends State<CommuteScreen> {
  String _selectedTab = 'all';

  // Seed rides scoped by campus
  List<CommuteRide> get _allRides {
    final activeCampusId = AuthState.instance.activeCampusId;
    return [
      CommuteRide(
        id: 'r1',
        from: 'Johar Town (G1 Market)',
        to: 'Campus Gate 3',
        time: '08:00 AM',
        price: 150,
        seats: 3,
        driverName: 'Bilal Ahmed',
        vehicle: 'Honda City (White)',
        campusId: activeCampusId,
      ),
      CommuteRide(
        id: 'r2',
        from: 'DHA Phase 5',
        to: 'Mechanical Engg Dept',
        time: '08:15 AM',
        price: 200,
        seats: 2,
        driverName: 'Zain Ali',
        vehicle: 'Toyota Yaris (Silver)',
        campusId: activeCampusId,
      ),
      CommuteRide(
        id: 'r3',
        from: 'Wapda Town Roundabout',
        to: 'Main Library',
        time: '08:30 AM',
        price: 120,
        seats: 1,
        driverName: 'Hamza Farooq',
        vehicle: 'Suzuki Alto',
        campusId: activeCampusId,
      ),
    ];
  }

  void _bookRide(CommuteRide ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book Seat?'),
        content: Text('Confirm booking 1 seat with ${ride.driverName} for Rs. ${ride.price}?\n\nPickup: ${ride.from}\nDropoff: ${ride.to}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seat booked! Driver notified via WhatsApp/SMS.')),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _offerRide() {
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController(text: 'Campus Gate');
    final timeCtrl = TextEditingController(text: '08:00 AM');
    final priceCtrl = TextEditingController(text: '150');
    final seatsCtrl = TextEditingController(text: '3');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Offer a Campus Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: fromCtrl, decoration: const InputDecoration(labelText: 'Pickup Point', hintText: 'Johar Town')),
              const SizedBox(height: 10),
              TextField(controller: toCtrl, decoration: const InputDecoration(labelText: 'Drop-off Point')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Departure Time'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (Rs.)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: seatsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seats'))),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ride offer posted to your campus commute board!')),
                  );
                },
                child: const Text('Post Ride Offer'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commute & Carpooling'),
            Text(
              campusName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Offer Ride',
            onPressed: _offerRide,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Carpools'),
                  selected: _selectedTab == 'all',
                  onSelected: (val) => setState(() => _selectedTab = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Campus Cycle Rentals'),
                  selected: _selectedTab == 'bikes',
                  onSelected: (val) => setState(() => _selectedTab = 'bikes'),
                ),
              ],
            ),
          ),

          Expanded(
            child: _selectedTab == 'bikes'
                ? _buildBikesView()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allRides.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ride = _allRides[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.directions_car, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        ride.driverName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rs. ${ride.price}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.my_location, size: 14, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      ride.from,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: AppColors.error),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      ride.to,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${ride.time} • ${ride.seats} seats left',
                                    style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(90, 34),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () => _bookRide(ride),
                                    child: const Text('Book Seat', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.pedal_bike, size: 28),
            title: const Text('Phoenix Campus MTB #04', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Station: Library Bike Dock • Rs. 20/hr'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 32)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cycle unlocked! Lock PIN: 4821')),
                );
              },
              child: const Text('Unlock', style: TextStyle(fontSize: 11)),
            ),
          ),
        ),
      ],
    );
  }
}
