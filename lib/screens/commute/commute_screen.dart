import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ride_model.dart';
import '../../services/commute_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/public_profile_dialog.dart';
import '../../widgets/review_modal.dart';
import '../messages/messages_screen.dart';
import '../search/campus_search_screen.dart';

class CommuteScreen extends StatefulWidget {
  const CommuteScreen({super.key});

  @override
  State<CommuteScreen> createState() => _CommuteScreenState();
}

class _CommuteScreenState extends State<CommuteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RideModel> _rides = [];
  List<BikeModel> _bikes = [];
  List<RideBookingModel> _bookings = [];
  bool _isLoading = true;
  String _selectedVehicleFilter = 'all';
  String _searchFrom = '';
  String _searchTo = '';

  final TextEditingController _searchFromCtrl = TextEditingController();
  final TextEditingController _searchToCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchFromCtrl.dispose();
    _searchToCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final campusId = AuthState.instance.activeCampusId;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        CommuteService.getRides(campusId: campusId),
        CommuteService.getBikes(campusId: campusId),
        CommuteService.getBookings(),
      ]);

      if (mounted) {
        setState(() {
          _rides = results[0] as List<RideModel>;
          _bikes = results[1] as List<BikeModel>;
          _bookings = results[2] as List<RideBookingModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<RideModel> get _filteredRides {
    var list = _rides;
    if (_selectedVehicleFilter != 'all') {
      list = list.where((r) => r.vehicleType == _selectedVehicleFilter).toList();
    }
    if (_searchFrom.trim().isNotEmpty) {
      final q = _searchFrom.trim().toLowerCase();
      list = list.where((r) => r.fromLocation.toLowerCase().contains(q) || r.pickupPoint.toLowerCase().contains(q)).toList();
    }
    if (_searchTo.trim().isNotEmpty) {
      final q = _searchTo.trim().toLowerCase();
      list = list.where((r) => r.toLocation.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _bookRide(RideModel ride) {
    if (ride.availableSeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, all seats for this ride are booked!')),
      );
      return;
    }

    final user = AuthState.instance.user;
    final riderName = user?.name ?? 'Student';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book Carpool Seat?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route: ${ride.fromLocation} → ${ride.toLocation}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text('Driver: ${ride.organizerName} (${ride.vehicleType.toUpperCase()})'),
            Text('Departure: ${ride.departureTime} (${ride.departureDate})'),
            Text('Pickup: ${ride.pickupPoint}'),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fare Per Seat:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Rs. ${ride.pricePerSeat}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await CommuteService.bookRideSeat(ride: ride, riderName: riderName);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Seat booked with ${ride.organizerName}! Driver notified.')),
                );
                _loadAllData();
              }
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showEditRideDialog(RideModel ride) {
    final fromCtrl = TextEditingController(text: ride.fromLocation);
    final toCtrl = TextEditingController(text: ride.toLocation);
    final timeCtrl = TextEditingController(text: ride.departureTime);
    final priceCtrl = TextEditingController(text: ride.pricePerSeat.toString());
    final seatsCtrl = TextEditingController(text: ride.availableSeats.toString());
    String vehicle = ride.vehicleType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fromCtrl,
                  decoration: const InputDecoration(labelText: 'From Location', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: toCtrl,
                  decoration: const InputDecoration(labelText: 'To Location', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: timeCtrl,
                        decoration: const InputDecoration(labelText: 'Time (e.g. 08:30 AM)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price / Seat (Rs)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: seatsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Seats Available', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: ['rickshaw', 'bike', 'car'].contains(vehicle.toLowerCase()) ? vehicle.toLowerCase() : 'rickshaw',
                        decoration: const InputDecoration(labelText: 'Vehicle', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'rickshaw', child: Text('Rickshaw')),
                          DropdownMenuItem(value: 'bike', child: Text('Bike')),
                          DropdownMenuItem(value: 'car', child: Text('Car')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => vehicle = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final from = fromCtrl.text.trim();
                final to = toCtrl.text.trim();
                final time = timeCtrl.text.trim();
                final price = int.tryParse(priceCtrl.text.trim()) ?? ride.pricePerSeat;
                final seats = int.tryParse(seatsCtrl.text.trim()) ?? ride.availableSeats;
                if (from.isEmpty || to.isEmpty) return;

                final scaffold = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                final success = await CommuteService.updateRide(
                  id: ride.id,
                  fromLocation: from,
                  toLocation: to,
                  departureTime: time,
                  pricePerSeat: price,
                  availableSeats: seats,
                  vehicleType: vehicle,
                );

                if (!mounted) return;
                if (success) {
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Ride updated successfully!')),
                  );
                  _loadAllData();
                } else {
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Failed to update ride.')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteRide(RideModel ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel and delete this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Ride'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await CommuteService.deleteRide(ride.id);
              if (!mounted) return;
              if (success) {
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Ride deleted successfully!')),
                );
                _loadAllData();
              } else {
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Failed to delete ride.')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _offerRide() {
    final user = AuthState.instance.user;
    final campusId = AuthState.instance.activeCampusId;
    final universityId = user?.universityId ?? 'uni_uet_lahore';
    final organizerName = user?.name ?? 'Student Driver';

    String vehicle = 'rickshaw';
    final fromCtrl = TextEditingController(text: 'Johar Town');
    final toCtrl = TextEditingController(text: 'Campus Gate 3');
    final timeCtrl = TextEditingController(text: '08:00 AM');
    final dateCtrl = TextEditingController(text: 'Today');
    final seatsCtrl = TextEditingController(text: '3');
    final totalFareCtrl = TextEditingController(text: '200');
    final priceCtrl = TextEditingController(text: '50');
    final pickupCtrl = TextEditingController(text: 'Main Chowk Shell Pump');
    final notesCtrl = TextEditingController();
    bool isPosting = false;

    void updatePrice(StateSetter setModalState) {
      final base = int.tryParse(totalFareCtrl.text.trim()) ?? (vehicle == 'rickshaw' ? 200 : vehicle == 'bike' ? 150 : 350);
      final s = int.tryParse(seatsCtrl.text) ?? 3;
      final perSeat = (base / (s > 0 ? s + 1 : 1)).round();
      priceCtrl.text = perSeat.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Offer a Campus Ride',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vehicle Selector Chips
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.electric_rickshaw, size: 16),
                        label: const Text('Rickshaw', style: TextStyle(fontSize: 12)),
                        selected: vehicle == 'rickshaw',
                        onSelected: (val) {
                          setModalState(() {
                            vehicle = 'rickshaw';
                            totalFareCtrl.text = '200';
                            seatsCtrl.text = '3';
                            updatePrice(setModalState);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.two_wheeler, size: 16),
                        label: const Text('Bike', style: TextStyle(fontSize: 12)),
                        selected: vehicle == 'bike',
                        onSelected: (val) {
                          setModalState(() {
                            vehicle = 'bike';
                            totalFareCtrl.text = '150';
                            seatsCtrl.text = '1';
                            updatePrice(setModalState);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Icon(Icons.directions_car, size: 16),
                        label: const Text('Car', style: TextStyle(fontSize: 12)),
                        selected: vehicle == 'car',
                        onSelected: (val) {
                          setModalState(() {
                            vehicle = 'car';
                            totalFareCtrl.text = '350';
                            seatsCtrl.text = '3';
                            updatePrice(setModalState);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // From Location
                TextField(
                  controller: fromCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Locality (From)',
                    hintText: 'e.g. Johar Town, Khurrianwala, DHA',
                    prefixIcon: Icon(Icons.my_location, size: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // To Location
                TextField(
                  controller: toCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destination (To)',
                    hintText: 'e.g. Main Campus Gate 3, CS Department',
                    prefixIcon: Icon(Icons.location_on, size: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // Time & Date
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: timeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Departure Time',
                          hintText: '08:00 AM',
                          prefixIcon: Icon(Icons.access_time, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: dateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          hintText: 'Today / Tomorrow',
                          prefixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Total Fare & Available Seats
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: totalFareCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Total ${vehicle == 'rickshaw' ? 'Rickshaw' : vehicle == 'bike' ? 'Bike' : 'Car'} Fare (Rs.)',
                          hintText: 'e.g. 200',
                          prefixIcon: const Icon(Icons.request_quote_outlined, size: 18),
                        ),
                        onChanged: (_) => updatePrice(setModalState),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: seatsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Available Seats',
                          prefixIcon: Icon(Icons.people_outline, size: 18),
                        ),
                        onChanged: (_) => updatePrice(setModalState),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price Per Seat
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fare / Seat for Passengers (Rs.)',
                    prefixIcon: Icon(Icons.payments_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // Pickup Stop & Notes
                TextField(
                  controller: pickupCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Stop Landmark',
                    hintText: 'e.g. Shell Pump Chowk',
                    prefixIcon: Icon(Icons.pin_drop_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes for Students (Optional)',
                    hintText: 'e.g. AC carpool, please be on time',
                    prefixIcon: Icon(Icons.info_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Post Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isPosting
                      ? null
                      : () async {
                          final fromText = fromCtrl.text.trim();
                          final toText = toCtrl.text.trim();
                          final timeText = timeCtrl.text.trim();
                          final seatsNum = int.tryParse(seatsCtrl.text.trim()) ?? 3;
                          final priceNum = int.tryParse(priceCtrl.text.trim()) ?? 50;
                          final totalFareNum = int.tryParse(totalFareCtrl.text.trim()) ?? (priceNum * (seatsNum + 1));

                          if (fromText.isEmpty || toText.isEmpty || timeText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter pickup, destination, and departure time')),
                            );
                            return;
                          }

                          setModalState(() => isPosting = true);

                          final createdRide = await CommuteService.createRide(
                            campusId: campusId,
                            universityId: universityId,
                            organizerId: user?.userId,
                            organizerName: organizerName,
                            fromLocation: fromText,
                            toLocation: toText,
                            departureTime: timeText,
                            departureDate: dateCtrl.text.trim().isEmpty ? 'Today' : dateCtrl.text.trim(),
                            vehicleType: vehicle,
                            totalCost: totalFareNum,
                            pricePerSeat: priceNum,
                            totalSeats: seatsNum + 1,
                            availableSeats: seatsNum,
                            pickupPoint: pickupCtrl.text.trim().isEmpty ? 'Main road stop' : pickupCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          );

                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                          }
                          if (mounted) {
                            setState(() {
                              _rides.insert(0, createdRide);
                              _tabController.animateTo(0);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ride offer posted successfully to your campus commute board!'),
                              ),
                            );
                          }
                        },
                  child: isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Post Ride Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRideDetails(RideModel ride) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    PublicProfileDialog.show(
                      context,
                      userId: ride.organizerName,
                      fallbackName: ride.organizerName,
                      fallbackVerified: ride.organizerVerified,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        _getVehicleIcon(ride.vehicleType),
                        const SizedBox(width: 8),
                        Text(
                          ride.organizerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 12, color: AppColors.zinc500),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Rs. ${ride.pricePerSeat} / seat',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.zinc900 : AppColors.zinc100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(ride.fromLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(height: 12, child: VerticalDivider(width: 2, thickness: 1)),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(ride.toLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Departure: ${ride.departureTime} • ${ride.departureDate}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Pickup Landmark: ${ride.pickupPoint}', style: const TextStyle(fontSize: 12)),
            if (ride.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${ride.notes}', style: const TextStyle(fontSize: 12, color: AppColors.zinc500)),
            ],
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final user = AuthState.instance.user;
                final currentUserName = (user != null && user.name.isNotEmpty)
                    ? user.name.trim().toLowerCase()
                    : '';
                final isMine = (currentUserName.isNotEmpty &&
                        ride.organizerName.trim().toLowerCase() == currentUserName) ||
                    (user != null &&
                        user.userId.isNotEmpty &&
                        ride.organizerId != null &&
                        ride.organizerId == user.userId);

                if (isMine) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEditRideDialog(ride);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Ride'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDeleteRide(ride);
                          },
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                          label: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: ride.availableSeats > 0
                      ? () {
                          Navigator.pop(ctx);
                          _bookRide(ride);
                        }
                      : null,
                  child: Text(ride.availableSeats > 0 ? 'Book a Seat (${ride.availableSeats} Left)' : 'Ride Fully Booked'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return const Icon(Icons.directions_car, size: 20);
      case 'bike':
        return const Icon(Icons.two_wheeler, size: 20);
      case 'rickshaw':
      default:
        return const Icon(Icons.electric_rickshaw, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusName = AuthState.instance.activeCampusName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Commute & Carpool',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            Text(
              campusName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            tooltip: 'Search Campus AI',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CampusSearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Offer a Ride',
            onPressed: _offerRide,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            Tab(text: 'Rides (${_rides.length})'),
            Tab(text: 'Bikes (${_bikes.length})'),
            Tab(text: 'My Bookings (${_bookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: RIDES
          _buildRidesTab(isDark),

          // TAB 2: BIKES
          _buildBikesTab(isDark),

          // TAB 3: MY BOOKINGS
          _buildBookingsTab(isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _offerRide,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Offer Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildRidesTab(bool isDark) {
    final filtered = _filteredRides;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips (All, Rickshaw, Bike, Car) - Horizontally Scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Vehicles', style: TextStyle(fontSize: 11)),
                  selected: _selectedVehicleFilter == 'all',
                  onSelected: (val) => setState(() => _selectedVehicleFilter = 'all'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  avatar: const Icon(Icons.electric_rickshaw, size: 14),
                  label: const Text('Rickshaw', style: TextStyle(fontSize: 11)),
                  selected: _selectedVehicleFilter == 'rickshaw',
                  onSelected: (val) => setState(() => _selectedVehicleFilter = 'rickshaw'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  avatar: const Icon(Icons.directions_car, size: 14),
                  label: const Text('Car', style: TextStyle(fontSize: 11)),
                  selected: _selectedVehicleFilter == 'car',
                  onSelected: (val) => setState(() => _selectedVehicleFilter = 'car'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  avatar: const Icon(Icons.two_wheeler, size: 14),
                  label: const Text('Bike', style: TextStyle(fontSize: 11)),
                  selected: _selectedVehicleFilter == 'bike',
                  onSelected: (val) => setState(() => _selectedVehicleFilter = 'bike'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Filter Inputs (From -> To)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchFromCtrl,
                  decoration: InputDecoration(
                    hintText: 'Filter pickup (e.g. Johar Town)',
                    hintStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Icon(Icons.search, size: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => setState(() => _searchFrom = val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchToCtrl,
                  decoration: InputDecoration(
                    hintText: 'Filter dropoff (e.g. Gate 3)',
                    hintStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Icon(Icons.location_on, size: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => setState(() => _searchTo = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Count header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} ride${filtered.length == 1 ? '' : 's'} available today',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: _offerRide,
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 14),
                    SizedBox(width: 2),
                    Text('Offer a ride', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtered.isEmpty)
            EmptyStateView(
              icon: Icons.electric_rickshaw,
              title: 'No Active Rides Found',
              message: 'No carpools or vehicle splits match your current search or campus filters.',
              actionLabel: 'Offer a Ride',
              onAction: _offerRide,
            )
          else
            ...filtered.map((ride) => _buildRideCard(ride, isDark)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideModel ride, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRideDetails(ride),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top line: Time & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        ride.departureTime,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ride.departureDate,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Rs. ${ride.pricePerSeat}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const Text(
                        ' / seat',
                        style: TextStyle(fontSize: 11, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Route & Vehicle
              Row(
                children: [
                  const Icon(Icons.my_location, size: 13, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${ride.fromLocation} → ${ride.toLocation}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                    ),
                    child: Text(
                      ride.vehicleType.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Bottom row: Driver & Seats & Book / Edit / Delete action
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        PublicProfileDialog.show(
                          context,
                          userId: ride.organizerName,
                          fallbackName: ride.organizerName,
                          fallbackVerified: ride.organizerVerified,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isDark ? AppColors.white : AppColors.black,
                            child: Text(
                              ride.organizerName.isNotEmpty ? ride.organizerName[0].toUpperCase() : 'S',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              ride.organizerName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: ride.availableSeats <= 1
                          ? (isDark ? AppColors.zinc800 : AppColors.zinc200)
                          : (isDark ? AppColors.white : AppColors.black),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ride.availableSeats > 0 ? '${ride.availableSeats} seat left' : 'Full',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ride.availableSeats <= 1
                            ? (isDark ? AppColors.white : AppColors.black)
                            : (isDark ? AppColors.black : AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Builder(
                    builder: (context) {
                      final user = AuthState.instance.user;
                      final currentUserName = (user != null && user.name.isNotEmpty)
                          ? user.name.trim().toLowerCase()
                          : '';
                      final isMine = (currentUserName.isNotEmpty &&
                              ride.organizerName.trim().toLowerCase() == currentUserName) ||
                          (user != null &&
                              user.userId.isNotEmpty &&
                              ride.organizerId != null &&
                              ride.organizerId == user.userId);

                      if (isMine) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _showEditRideDialog(ride),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.edit_outlined, size: 15, color: isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _confirmDeleteRide(ride),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.delete_outline, size: 15, color: AppColors.error),
                              ),
                            ),
                          ],
                        );
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(64, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: ride.availableSeats > 0 ? () => _bookRide(ride) : null,
                        child: const Text('Book', style: TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showListBikeDialog() {
    final modelCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '150');
    final depositCtrl = TextEditingController(text: '500');
    final locationCtrl = TextEditingController(text: 'Campus Hostel Parking');
    final rulesCtrl = TextEditingController(text: 'Return before 10 PM. Student card required.');
    String condition = 'Good condition';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('List Your Bike for Rent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(modalCtx)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Help campus peers get around university while earning daily rental income.', style: TextStyle(fontSize: 11, color: AppColors.zinc500)),
                const SizedBox(height: 14),
                TextField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: 'Bicycle / Scooter Model', hintText: 'e.g. Phoenix Mountain Bike, Sohrab Classic'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Daily Rent (Rs)', prefixText: 'Rs. '),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: depositCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Security Deposit (Rs)', prefixText: 'Rs. '),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Pickup Location on Campus', hintText: 'e.g. Hostel 4 Stand, Library Gate'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: condition,
                  decoration: const InputDecoration(labelText: 'Vehicle Condition'),
                  items: const [
                    DropdownMenuItem(value: 'Like New', child: Text('Like New')),
                    DropdownMenuItem(value: 'Good condition', child: Text('Good condition')),
                    DropdownMenuItem(value: 'Fair / Usable', child: Text('Fair / Usable')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => condition = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: rulesCtrl,
                  decoration: const InputDecoration(labelText: 'Rental Terms / Rules', hintText: 'e.g. Return with lock key by 9 PM'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final model = modelCtrl.text.trim();
                          final rate = int.tryParse(rateCtrl.text.trim()) ?? 150;
                          final deposit = int.tryParse(depositCtrl.text.trim()) ?? 500;
                          final location = locationCtrl.text.trim();
                          if (model.isEmpty || location.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter bike model and pickup location.')),
                            );
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          final user = AuthState.instance.user;
                          final bike = await CommuteService.listBike(
                            model: model,
                            dailyRate: rate,
                            depositAmount: deposit,
                            location: location,
                            condition: condition,
                            rules: rulesCtrl.text.trim(),
                            ownerName: user?.name ?? 'Student',
                            campusId: AuthState.instance.activeCampusId,
                          );
                          if (modalCtx.mounted) Navigator.pop(modalCtx);
                          if (bike != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Your bike is now listed for campus rental!'), backgroundColor: AppColors.success),
                            );
                            _loadAllData();
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('List Bike Now', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBikesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Action Banner to list a bike
        Card(
          color: isDark ? AppColors.zinc900 : AppColors.zinc100,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.two_wheeler, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Have a bicycle or scooter?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      Text('Rent it to trusted students when not in use.', style: TextStyle(fontSize: 11, color: AppColors.zinc500)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(90, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: _showListBikeDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('List Bike', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_bikes.isEmpty)
          EmptyStateView(
            icon: Icons.pedal_bike,
            title: 'No Bikes Listed for Rent',
            message: 'No cycles or scooters are currently listed in your campus. Be the first to list one!',
            actionLabel: 'List Your Bike',
            onAction: _showListBikeDialog,
          )
        else
          ..._bikes.map(
            (b) {
              final user = AuthState.instance.user;
              final isOwner = user != null && b.ownerName != null &&
                  b.ownerName!.trim().toLowerCase() == user.name.trim().toLowerCase();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                              const Icon(Icons.pedal_bike, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                b.model,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            'Rs. ${b.dailyRate} / day',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${b.location} • ${b.condition}',
                        style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                      ),
                      Text(
                        'Timing: ${b.availableTime} (${b.availableDate})',
                        style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                      ),
                      if (b.rules.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Terms: ${b.rules}',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.zinc500),
                        ),
                      ],
                      const Divider(height: 16),
                      // Owner & actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (b.ownerName != null) {
                                  PublicProfileDialog.show(
                                    context,
                                    userId: b.ownerName!,
                                    fallbackName: b.ownerName!,
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: isDark ? AppColors.zinc800 : AppColors.zinc300,
                                    child: Text(
                                      (b.ownerName != null && b.ownerName!.isNotEmpty) ? b.ownerName![0].toUpperCase() : 'O',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      b.ownerName ?? 'Student Owner',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new, size: 11, color: AppColors.zinc500),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              if (!isOwner) ...[
                                TextButton(
                                  onPressed: () {
                                    ReviewModal.show(
                                      context,
                                      targetUserId: b.ownerName ?? 'Owner',
                                      targetName: b.ownerName ?? 'Bike Owner',
                                      category: 'rental',
                                    );
                                  },
                                  child: const Text('Rate Owner', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(80, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Rent ${b.model}?'),
                                        content: Text(
                                          'Location: ${b.location}\nDaily Rate: Rs. ${b.dailyRate}\nSecurity Deposit: Rs. ${b.depositAmount}\n\nTerms: ${b.rules}\n\nNote: Handover and payments are coordinated directly with the student owner upon meetup.',
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(ctx);
                                              final success = await CommuteService.rentBike(
                                                bikeId: b.id,
                                                renterName: user?.name ?? 'Student',
                                                renterId: user?.userId,
                                              );
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(success
                                                        ? 'Rental request sent to ${b.ownerName}! Coordinate handover directly.'
                                                        : 'Could not send request. Please try again.'),
                                                    backgroundColor: success ? AppColors.success : AppColors.error,
                                                  ),
                                                );
                                                _loadAllData();
                                              }
                                            },
                                            child: const Text('Confirm Request'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('Rent Bike', style: TextStyle(fontSize: 11)),
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  tooltip: 'Delete Listing',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('Delete Bike Listing?'),
                                        content: const Text('Are you sure you want to remove your bicycle from the campus rental board?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.pop(dCtx, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final deleted = await CommuteService.deleteBike(b.id);
                                      if (deleted && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Bike listing removed.')),
                                        );
                                        _loadAllData();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBookingsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_bookings.isEmpty)
          EmptyStateView(
            icon: Icons.confirmation_number_outlined,
            title: 'No Active Ride Bookings',
            message: 'You haven’t booked any commute rides yet. Check the Available Rides tab to join an existing carpool or rickshaw split.',
            actionLabel: 'Browse Available Rides',
            onAction: () => _tabController.animateTo(0),
          )
        else
          ..._bookings.map(
            (booking) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CONFIRMED RIDE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        Text(
                          booking.departureTime,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      booking.route,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        PublicProfileDialog.show(
                          context,
                          userId: booking.organizerName,
                          fallbackName: booking.organizerName,
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Organizer: ${booking.organizerName} • ${booking.vehicleType.toUpperCase()}',
                            style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new, size: 11, color: AppColors.zinc500),
                        ],
                      ),
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cost Share: Rs. ${booking.pricePerSeat}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                ReviewModal.show(
                                  context,
                                  targetUserId: booking.organizerName,
                                  targetName: booking.organizerName,
                                  category: 'commute',
                                );
                              },
                              icon: const Icon(Icons.star_outline, size: 14),
                              label: const Text('Rate Driver', style: TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                                );
                              },
                              icon: const Icon(Icons.chat_outlined, size: 14),
                              label: const Text('Chat', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
