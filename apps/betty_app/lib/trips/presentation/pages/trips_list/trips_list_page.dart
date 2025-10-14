import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../trip_detail/trip_detail_page.dart';
import '../create_trip/create_trip_page.dart';
import 'widgets/trip_card.dart';
import 'widgets/empty_trips_view.dart';

class TripsListPage extends StatelessWidget {
  const TripsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TripProvider>().loadAllTrips();
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripProvider.trips.isEmpty) {
            return const EmptyTripsView();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripProvider.trips.length,
            itemBuilder: (context, index) {
              final trip = tripProvider.trips[index];
              return TripCard(
                trip: trip,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailPage(tripId: trip.id)));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripPage()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Viaje'),
      ),
    );
  }
}
