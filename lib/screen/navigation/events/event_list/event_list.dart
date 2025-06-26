import 'package:event_mng_sys/model/eventModel.dart';
import 'package:event_mng_sys/provider.dart';
import 'package:event_mng_sys/widget/cardCategory.dart';
import 'package:event_mng_sys/widget/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:event_mng_sys/screen/navigation/events/event_list/event_detail.dart';
import 'package:event_mng_sys/services/event_service.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  List<Event> _events = [];
  bool _isLoading = true;
  // Create an instance of the service
  final EventListService _eventService = EventListService();
  String _searchText = '';
  String? _selectedCategory; // null means "all"
  int _eventCount = 0;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        _isLoading = true; // Show loading spinner
      });
      final events = await _eventService.fetchEvents(
        searchText: _searchText, // from your TextField
        selectedCategory: _selectedCategory,
      ); // Use the service to fetch events
      if (!mounted) return; // Avoid setState after widget dispose
      setState(() {
        _events = events;
        _eventCount = events.length;
        _isLoading = false; // Stop loading once the events are fetched
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading if there's an error
      });
      // Handle error (you can show a SnackBar or dialog if needed)
      print("Error: $e");
    }
  }

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<UserProvider>(context).appUser;

    return Scaffold(
      backgroundColor: Color(0xFF6759FF),

      appBar: AppBar(
        title: const Text(
          'All Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF6759FF),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: Container(
                  //       color: Color(0xFF6759FF),
                  //       child: Column(children: [topScreenUI()]),
                  //     ),
                  //   ),
                  // ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // Purple curved background
                        Container(
                          padding: EdgeInsets.all(16),
                          child: IntrinsicHeight(
                            child: topScreenUI(appUser!.firstName),
                          ),
                          // adjust height as needed
                          decoration: const BoxDecoration(
                            // color: Color(0xFF6759FF),
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                        ),

                        // White top screen content slightly overlapping
                        // Positioned(
                        //   top: 10, // control how much overlap you want
                        //   left: 0,
                        //   right: 0,
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16.0,
                        //     ),
                        //     child: Container(
                        //       padding: const EdgeInsets.all(16),
                        //       decoration: BoxDecoration(
                        //         color: Colors.red,
                        //         borderRadius: BorderRadius.circular(20),
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.black12,
                        //             blurRadius: 10,
                        //             offset: Offset(0, 4),
                        //           ),
                        //         ],
                        //       ),
                        //       child: topScreenUI(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  _events.isEmpty
                      ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Center(
                            child: Text(
                              "No events found",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      )
                      : SliverList(delegate: SliverChildListDelegate(cardUi())),
                ],
              ),
    );
  }

  Widget catagoryUi() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          cardCategory(Icons.games, "Gaming", () {
            setState(() {
              _selectedCategory = 'Gaming'; // or null to reset
              _searchText = '';
              searchController.clear();
            });
            fetchEvents();
          }),
          cardCategory(Icons.sports_basketball, "Basketball", () {
            setState(() {
              _selectedCategory = 'Basketball'; // or null to reset
              _searchText = '';
              searchController.clear();
            });
            fetchEvents();
          }),
          cardCategory(Icons.library_books, "Education", () {
            setState(() {
              _selectedCategory = 'Education'; // or null to reset
              _searchText = '';
              searchController.clear();
            });
            fetchEvents();
          }),
          cardCategory(Icons.fitness_center, "Fitness", () {
            setState(() {
              _selectedCategory = 'Fitness'; // or null to reset
              _searchText = '';
              searchController.clear();
            });
            fetchEvents();
          }),
          cardCategory(Icons.fastfood, "Food", () {
            setState(() {
              _selectedCategory = 'Food'; // or null to reset
              _searchText = '';
              searchController.clear();
            });
            fetchEvents();
          }),
        ],
      ),
    );
  }

  Widget topScreenUI(dynamic firstname) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, ${firstname}",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "There are $_eventCount event in your location",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: customTextField(
            onSubmitted: (val) {
              setState(() {
                _searchText = val;
                _selectedCategory = null;
              });
              fetchEvents();
            },
            hint: "Search",
            controller: searchController,
            prefixIcon: Icons.search,
          ),
        ),

        catagoryUi(),
        Text(
          "Upcoming Events",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<Widget> cardUi() {
    return _events.map((event) {
      return GestureDetector(
        onTap: () {
          print(event.eventId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      EventDetailScreen(eventId: event.eventId, myevent: false),
            ),
          );
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  event.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 60,
                  left: 16,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${event.date}",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          event.location,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
