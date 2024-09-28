import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'review_page.dart';
import 'login_page.dart';

void main() => runApp(SafetyApp());

class SafetyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF13B9FD), // Light Blue
        scaffoldBackgroundColor: Colors.white, // White background
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // White footer background
          selectedItemColor: Color(0xFF13B9FD), // Light Blue for selected item
          unselectedItemColor: Colors.black, // Black for unselected items
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Black text
          bodyMedium: TextStyle(color: Colors.black), // Black text
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // White background for AppBar
          iconTheme: IconThemeData(color: Color(0xFF13B9FD)), // Light blue for icons
          titleTextStyle: TextStyle(color: Color(0xFF13B9FD), fontSize: 20), // Light blue title
        ),
      ),
      home: LoginSignupPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages for navigation
  static List<Widget> _pages = <Widget>[
    LiveLocationMap(),
    NewsScreen(),
    ProfileScreen(),
    SafetyHeatmapScreen(), // Add Heatmap screen here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety App', style: TextStyle(color: Color(0xFF13B9FD))),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.heat_pump), // Use an appropriate icon for heatmap
            label: 'Heatmap',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF13B9FD), // Light blue for selected
        unselectedItemColor: Colors.black, // Black for unselected
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home page widget for Live Location Map
class LiveLocationMap extends StatefulWidget {
  @override
  _LiveLocationMapState createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  MapController mapController = MapController();
  Location location = Location();
  LatLng _currentPosition = LatLng(51.509865, -0.118092); // Default to London
  bool _isLoading = true;
  HeatmapData? _heatmapData;

  LatLng? _sourcePosition;
  LatLng? _destinationPosition;
  List<LatLng> _routePoints = []; // For storing route points

  // Controllers for text fields
  TextEditingController _sourceController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadHeatmapData(); // Load heatmap data when the map initializes
  }

  // Get current live location of user
  Future<void> _getCurrentLocation() async {
    LocationData currentLocation = await location.getLocation();
    setState(() {
      _currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _isLoading = false;
    });

    // Move the map to the current location
    mapController.move(_currentPosition, 15.0);
  }

  // Load heatmap data from JSON file
  Future<void> _loadHeatmapData() async {
    HeatmapData heatmapData = await HeatmapData.fromJsonFile('heatmap_data.json'); // Replace with correct path
    setState(() {
      _heatmapData = heatmapData;
    });
  }

  // Function to create heatmap markers (using circles for visual simulation)
  List<CircleMarker> _createHeatmapMarkers() {
    if (_heatmapData == null) return [];

    List<CircleMarker> heatmapMarkers = [];

    for (int i = 0; i < _heatmapData!.locations.length; i++) {
      heatmapMarkers.add(
        CircleMarker(
          point: _heatmapData!.locations[i],
          color: Color(0xFF13B9FD).withOpacity(_heatmapData!.intensity[i] / 100), // Light blue
          radius: _heatmapData!.intensity[i].toDouble(), // intensity affects the circle size
        ),
      );
    }

    return heatmapMarkers;
  }

  // Function to get the coordinates of a location name (geocoding)
  Future<LatLng?> _getCoordinatesFromLocation(String locationName) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$locationName&format=json&limit=1'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  // Function to get route between source and destination
  Future<void> _getRoute(LatLng source, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62489368cd10ca494b649395917e4d82cbbb&start=${source.longitude},${source.latitude}&end=${destination.longitude},${destination.latitude}'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];
      List<LatLng> routePoints = coordinates
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();

      setState(() {
        _routePoints = routePoints;
      });
    } else {
      print('Failed to load route');
    }
  }

  // Start routing after getting source and destination locations
  Future<void> _startRouting() async {
    String sourceLocation = _sourceController.text;
    String destinationLocation = _destinationController.text;

    LatLng? sourceCoords = await _getCoordinatesFromLocation(sourceLocation);
    LatLng? destinationCoords = await _getCoordinatesFromLocation(destinationLocation);

    if (sourceCoords != null && destinationCoords != null) {
      setState(() {
        _sourcePosition = sourceCoords;
        _destinationPosition = destinationCoords;
      });

      // Move the map to the source location
      mapController.move(sourceCoords, 10.0);

      // Fetch and display the route
      await _getRoute(sourceCoords, destinationCoords);
    } else {
      print('Could not find one or both locations.');
    }
  }

  // Function to create markers for live location, source, and destination
  List<Marker> _createLocationMarkers() {
    List<Marker> markers = [];

    // Add live location marker
    markers.add(
      Marker(
        point: _currentPosition,
        builder: (ctx) => Icon(Icons.my_location, color: Color(0xFF13B9FD), size: 40),
      ),
    );

    // Add source location marker if available
    if (_sourcePosition != null) {
      markers.add(
        Marker(
          point: _sourcePosition!,
          builder: (ctx) => Icon(Icons.location_on, color: Colors.green, size: 40),
        ),
      );
    }

    // Add destination location marker if available
    if (_destinationPosition != null) {
      markers.add(
        Marker(
          point: _destinationPosition!,
          builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location, Routing, and Heatmap'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _sourceController,
                    decoration: InputDecoration(labelText: 'Source Location'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(labelText: 'Destination Location'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _startRouting,
                  child: Text('Get Route'),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: _currentPosition,
                      zoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: _createLocationMarkers(),
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      CircleLayer(
                        circles: _createHeatmapMarkers(), // Create heatmap markers
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewPage()),
                      );
                    },
                    child: Text('Add a Review'),
                  ),
                ),
              ],
            ),
    );
  }
}

// Screen for displaying news articles
class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<dynamic>> newsArticles;

  @override
  void initState() {
    super.initState();
    newsArticles = fetchNews(); // Fetch the news when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Latest Crime News',
    style: TextStyle(color: Colors.black), // Set the text color to black
  ),
  backgroundColor: Color(0xFF13B9FD), // AppBar color
  foregroundColor: Colors.black, // Set the default icon and text color to black
),
      body: FutureBuilder<List<dynamic>>(
        future: newsArticles,
        builder: (context, snapshot) {
          // While the data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF13B9FD)));
          }
          // If there's an error
          else if (snapshot.hasError) {
            return Center(child: Text('Failed to load news', style: TextStyle(color: Colors.black)));
          }
          // Once the data is fetched
          else if (snapshot.hasData && snapshot.data != null) {
            List<dynamic> articles = snapshot.data!;

            // Show the top 10 articles
            return ListView.builder(
              itemCount: articles.length > 10 ? 10 : articles.length,
              itemBuilder: (context, index) {
                var article = articles[index];
                return NewsItem(
                  title: article['title'] ?? 'No title',
                  source: article['source'] != null ? article['source']['name'] : 'Unknown source',
                  publishedAt: article['publishedAt'] ?? 'Unknown date',
                  url: article['url'] ?? '',
                );
              },
            );
          } else {
            return Center(child: Text('No news available', style: TextStyle(color: Colors.black)));
          }
        },
      ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final String title;
  final String source;
  final String publishedAt;
  final String url;

  NewsItem({
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.black)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source: $source', style: TextStyle(color: Colors.black)),
            Text('Published at: $publishedAt', style: TextStyle(color: Colors.black)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: Color(0xFF13B9FD)),
        onTap: () {
          // When tapped, open the article URL
          _launchURL(context, url);
        },
      ),
    );
  }

  // Open the news article in a web browser
  void _launchURL(BuildContext context, String url) async {
  // Using launchUrl instead of launch
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the URL')),
    );
  }
}

}

// Screen for displaying user profile
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('User Profile Coming Soon!'),
      ),
    );
  }
}

// Heatmap data model
class HeatmapData {
  final List<LatLng> locations;
  final List<int> intensity;

  HeatmapData({required this.locations, required this.intensity});

  // Load heatmap data from a JSON file
  static Future<HeatmapData> fromJsonFile(String filePath) async {
    final file = File(filePath);
    String jsonString = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(jsonString);
    List<LatLng> locations = (json['locations'] as List)
        .map((loc) => LatLng(loc[0], loc[1]))
        .toList();
    List<int> intensity = (json['intensity'] as List).map((i) => i as int).toList();
    return HeatmapData(locations: locations, intensity: intensity);
  }
}

// Heatmap screen placeholder
class SafetyHeatmapScreen extends StatefulWidget {
  @override
  _SafetyHeatmapScreenState createState() => _SafetyHeatmapScreenState();
}

class _SafetyHeatmapScreenState extends State<SafetyHeatmapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 2.0;
  LatLng _mapCenter = LatLng(20, 0);

  late List<HeatmapDataPoint> heatmapData;

  @override
  void initState() {
    super.initState();
    heatmapData = _initializeHeatmapData(); // Initialize heatmap data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Safety Heatmap", style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFF13B9FD),
        foregroundColor: Colors.black,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _mapCenter,
          zoom: _currentZoom,
          onPositionChanged: (position, hasGesture) {
            setState(() {
              _currentZoom = position.zoom!;
              _mapCenter = position.center!;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: SafetyHeatmapPainter(
              heatmapData: heatmapData,
              mapController: _mapController,
              zoom: _currentZoom,
              maxIntensity: 5,
            ),
          ),
        ],
      ),
    );
  }

  // Function to initialize heatmap data
  List<HeatmapDataPoint> _initializeHeatmapData() {
    return [
      // High-Risk Areas (Red)
      HeatmapDataPoint(LatLng(28.7041, 77.1025), 1), // Delhi (High Risk)
      HeatmapDataPoint(LatLng(22.5726, 88.3639), 1), // Kolkata (High Risk)
      HeatmapDataPoint(LatLng(26.8467, 80.9462), 1), // Lucknow (High Risk)
      HeatmapDataPoint(LatLng(25.3176, 82.9739), 1), // Varanasi (High Risk)
      HeatmapDataPoint(LatLng(24.5854, 73.7125), 1), // Udaipur (High Risk)

      // Moderate-Risk Areas (Yellow)
      HeatmapDataPoint(LatLng(12.9716, 77.5946), 3), // Bengaluru (Medium Risk)
      HeatmapDataPoint(LatLng(13.0827, 80.2707), 3), // Chennai (Medium Risk)
      HeatmapDataPoint(LatLng(17.3850, 78.4867), 3), // Hyderabad (Medium Risk)
      HeatmapDataPoint(LatLng(23.0225, 72.5714), 3), // Ahmedabad (Medium Risk)
      HeatmapDataPoint(LatLng(21.1702, 72.8311), 3), // Surat (Medium Risk)
      HeatmapDataPoint(LatLng(19.0760, 72.8777), 3), // Mumbai (Medium Risk)

      // Low-Risk Areas (Green)
      HeatmapDataPoint(LatLng(11.0168, 76.9558), 5), // Coimbatore (Safe)
      HeatmapDataPoint(LatLng(15.3173, 75.7139), 5), // Hubli (Safe)
      HeatmapDataPoint(LatLng(18.5204, 73.8567), 5), // Pune (Safe)
      HeatmapDataPoint(LatLng(30.7333, 76.7794), 5), // Chandigarh (Safe)
      HeatmapDataPoint(LatLng(22.7196, 75.8577), 5), // Indore (Safe)
      HeatmapDataPoint(LatLng(32.7266, 74.8570), 5), // Jammu (Safe)
      HeatmapDataPoint(LatLng(23.2599, 77.4126), 5), // Bhopal (Safe)
      HeatmapDataPoint(LatLng(20.2961, 85.8245), 5), // Bhubaneswar (Safe)

      // Additional Moderate and High-Risk areas can be added here
    ];
  }
}

class HeatmapDataPoint {
  final LatLng location;
  final int intensity;

  HeatmapDataPoint(this.location, this.intensity);
}

class SafetyHeatmapPainter extends CustomPainter {
  final List<HeatmapDataPoint> heatmapData;
  final MapController mapController;
  final double zoom;
  final int maxIntensity;

  SafetyHeatmapPainter({
    required this.heatmapData,
    required this.mapController,
    required this.zoom,
    required this.maxIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final dataPoint in heatmapData) {
      final Offset point = _latLngToOffset(dataPoint.location, size);
      paint.color = _getColorForIntensity(dataPoint.intensity);
      double circleSize = (zoom * 2);
      canvas.drawCircle(point, circleSize, paint);
    }
  }

  Offset _latLngToOffset(LatLng latLng, Size size) {
    final projPoint = mapController.latLngToScreenPoint(latLng);
    return Offset(projPoint!.x, projPoint.y);
  }

  // Function to assign colors based on safety rating
  Color _getColorForIntensity(int intensity) {
    double normalizedValue = intensity / maxIntensity;
    int alpha = 255; // Fully opaque

    if (intensity == 5) {
      alpha = (0.9 * 255).toInt(); // Safe areas (green)
    } else if (intensity == 3 || intensity == 4) {
      alpha = (0.8 * 255).toInt(); // Moderate-risk areas (yellow)
    } else if (intensity == 1 || intensity == 2) {
      alpha = (0.7 * 255).toInt(); // High-risk areas (red)
    }

    return Color.fromARGB(
      alpha,
      (Color.fromARGB(255, 52, 199, 57).red +
              (Colors.red.red - Color.fromARGB(255, 52, 199, 57).red) *
                  normalizedValue)
          .toInt(),
      (Color.fromARGB(255, 52, 199, 57).green +
              (Colors.red.green - Color.fromARGB(255, 52, 199, 57).green) *
                  normalizedValue)
          .toInt(),
      (Color.fromARGB(255, 52, 199, 57).blue +
              (Colors.red.blue - Color.fromARGB(255, 52, 199, 57).blue) *
                  normalizedValue)
          .toInt(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}