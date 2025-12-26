// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
// HIDE Path to avoid conflicts
import 'package:flutter_map/flutter_map.dart' hide Path;
import 'package:latlong2/latlong.dart' hide Path;

import '../widgets/glass_scaffold.dart';
import '../widgets/search_bar.dart';
import '../widgets/resource_carousel_card.dart';
import '../widgets/resource_filters.dart';
import '../widgets/resource_detail_sheet.dart';
import '../widgets/post_preview.dart';
import '../widgets/glass_card.dart';
import '../widgets/avatar.dart';
import '../theme/design_tokens.dart';
import '../data/search_repository.dart';
import '../models/resource.dart';
import '../models/user.dart';
import '../models/post.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchRepository _repository = SearchRepository();
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // State
  int _selectedTabIndex = 0; // 0: Community, 1: People, 2: Resources
  String _searchQuery = "";
  ResourceCategory? _selectedCategory;

  // Data - Nullable to prevent LateInitializationError
  Future<List<Post>>? _postsFuture;
  Future<List<User>>? _usersFuture;
  List<Resource> _allResources = [];
  bool _isLoadingResources = true;

  @override
  void initState() {
    super.initState();
    // Initialize futures immediately
    _postsFuture = _repository.searchPosts("");
    _usersFuture = _repository.searchUsers("");

    _repository
        .getNearbyResources()
        .then((value) {
          if (mounted) {
            setState(() {
              _allResources = value;
              _isLoadingResources = false;
            });
          }
        })
        .catchError((e) {
          if (mounted) setState(() => _isLoadingResources = false);
        });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _postsFuture = _repository.searchPosts(query);
      _usersFuture = _repository.searchUsers(query);
    });
  }

  List<Resource> get _filteredResources {
    if (_selectedCategory == null) return _allResources;
    return _allResources.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMapMode = _selectedTabIndex == 2;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- LAYER 0: Background ---
          IndexedStack(
            index: isMapMode ? 1 : 0,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.5, -0.6),
                    radius: 1.2,
                    colors: [
                      DesignTokens.backgroundTop,
                      DesignTokens.backgroundBottom,
                      Color(0xFFE6E6FA),
                    ],
                  ),
                ),
              ),
              _buildMapLayer(),
            ],
          ),

          // --- LAYER 1: Foreground Content ---
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassSearchBar(onChanged: _onSearchChanged),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildGlassTabBar(),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildCommunityTab(),
                      _buildPeopleTab(),
                      _buildResourcesOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MAP LAYER ---
  Widget _buildMapLayer() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(
          SearchRepository.centerLat,
          SearchRepository.centerLng,
        ),
        initialZoom: 13.5,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        MarkerLayer(
          markers: _filteredResources.map((resource) {
            return Marker(
              point: LatLng(resource.latitude, resource.longitude),
              width: 50,
              height: 50,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  _mapController.move(
                    LatLng(resource.latitude, resource.longitude),
                    15,
                  );
                  final index = _filteredResources.indexOf(resource);
                  if (index != -1) {
                    _pageController.animateToPage(
                      index,
                      duration: DesignTokens.durationMedium,
                      curve: DesignTokens.animationCurve,
                    );
                  }
                },
                child: _buildGlassMarker(resource),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- TAB 3: RESOURCES OVERLAY ---
  Widget _buildResourcesOverlay() {
    return Column(
      children: [
        ResourceFilters(
          selectedCategory: _selectedCategory,
          onCategorySelected: (cat) {
            setState(() => _selectedCategory = cat);
          },
        ),

        const Spacer(),

        // FIX: Increased height from 190 to 260 to fit the new professional card
        if (_allResources.isNotEmpty)
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _filteredResources.length,
              onPageChanged: (index) {
                final r = _filteredResources[index];
                _mapController.move(LatLng(r.latitude, r.longitude), 15);
              },
              itemBuilder: (context, index) {
                return ResourceCarouselCard(
                  resource: _filteredResources[index],
                  onTap: () => _showResourceDetails(_filteredResources[index]),
                );
              },
            ),
          ),

        const SizedBox(height: 90),
      ],
    );
  }

  void _showResourceDetails(Resource resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResourceDetailSheet(resource: resource),
    );
  }

  // --- TAB 1 & 2 ---
  Widget _buildCommunityTab() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text("No posts found."));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: snapshot.data!.length,
          itemBuilder: (c, i) => PostPreview(post: snapshot.data![i]),
        );
      },
    );
  }

  Widget _buildPeopleTab() {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text("No users found."));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: snapshot.data!.length,
          itemBuilder: (c, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: ListTile(
                leading: Avatar(user: snapshot.data![i], radius: 24),
                title: Text(
                  snapshot.data![i].displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("@${snapshot.data![i].username}"),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPERS ---
  Widget _buildGlassTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: DesignTokens.glassWhite.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: DesignTokens.glassBorder),
      ),
      child: Row(
        children: [
          _buildTabItem("Community", 0),
          _buildTabItem("People", 1),
          _buildTabItem("Resources", 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? DesignTokens.accentPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : DesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMarker(Resource resource) {
    Color color = DesignTokens.accentPrimary;
    if (resource.category == ResourceCategory.police) color = Colors.blue;
    if (resource.category == ResourceCategory.medical) color = Colors.red;
    if (resource.category == ResourceCategory.legal) color = Colors.indigo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getIconForCategory(resource.category),
            color: Colors.white,
            size: 18,
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: 10,
            height: 8,
            color: color.withOpacity(0.95),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(ResourceCategory cat) {
    switch (cat) {
      case ResourceCategory.police:
        return Icons.local_police;
      case ResourceCategory.medical:
        return Icons.local_hospital;
      case ResourceCategory.shelter:
        return Icons.home;
      case ResourceCategory.legal:
        return Icons.gavel;
      default:
        return Icons.place;
    }
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
