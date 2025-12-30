// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
// HIDE Path to avoid conflicts with Flutter rendering
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
import '../widgets/bottom_nav.dart';
import '../widgets/top_nav.dart';
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

  // Data
  Future<List<Post>>? _postsFuture;
  Future<List<User>>? _usersFuture;
  List<Resource> _allResources = [];
  bool _isLoadingResources = true;

  @override
  void initState() {
    super.initState();
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

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
  }

  void _onCategorySelected(ResourceCategory? category) {
    setState(() => _selectedCategory = category);
  }

  List<Resource> get _filteredResources {
    if (_selectedCategory == null) return _allResources;
    return _allResources.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMapMode = _selectedTabIndex == 2;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark
          ? DesignTokens.backgroundTopDark
          : DesignTokens.backgroundTop,
      body: Stack(
        children: [
          // --- LAYER 0: Background & Map ---
          IndexedStack(
            index: isMapMode ? 1 : 0,
            children: [
              _SearchBackground(isDark: isDark),
              _MapLayer(
                mapController: _mapController,
                resources: _filteredResources,
                pageController: _pageController,
                isDark: isDark,
              ),
            ],
          ),

          // --- LAYER 1: Foreground Content ---
          Column(
            children: [
              // 1. Top Nav
              const TopNav(
                title: "Explore",
                showBack: false,
                showSettings: false,
                showNotificationIcon: true,
              ),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassSearchBar(onChanged: _onSearchChanged),
              ),
              const SizedBox(height: 12),

              // 3. Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchTabBar(
                  selectedIndex: _selectedTabIndex,
                  onTabChanged: _onTabChanged,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 12),

              // 4. Content Views
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _CommunityList(postsFuture: _postsFuture),
                    _PeopleList(usersFuture: _usersFuture),
                    _ResourcesOverlay(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _onCategorySelected,
                      resources: _filteredResources,
                      pageController: _pageController,
                      mapController: _mapController,
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- LAYER 2: Bottom Nav ---
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(currentIndex: 1), // Index 1 is Search
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS (Refactored for Modularity & Theming)
// =============================================================================

class _SearchBackground extends StatelessWidget {
  final bool isDark;
  const _SearchBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.6),
          radius: 1.2,
          colors: isDark
              ? [
                  DesignTokens.backgroundTopDark,
                  DesignTokens.backgroundBottomDark,
                  const Color(0xFF1E1E2C), // Deep accent for dark mode
                ]
              : [
                  DesignTokens.backgroundTop,
                  DesignTokens.backgroundBottom,
                  const Color(0xFFE6E6FA), // Lavender for light mode
                ],
        ),
      ),
    );
  }
}

class _SearchTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final bool isDark;

  const _SearchTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.glassDark
            : DesignTokens.glassWhite.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? DesignTokens.glassBorderDark
              : DesignTokens.glassBorder,
        ),
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
    final bool isSelected = selectedIndex == index;

    // Determine Text Color
    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else {
      textColor = isDark
          ? DesignTokens.textPrimaryDark
          : DesignTokens.textPrimary;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
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
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityList extends StatelessWidget {
  final Future<List<Post>>? postsFuture;
  const _CommunityList({required this.postsFuture});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Post>>(
      future: postsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No posts found.",
              style: TextStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          itemCount: snapshot.data!.length,
          itemBuilder: (c, i) => PostPreview(post: snapshot.data![i]),
        );
      },
    );
  }
}

class _PeopleList extends StatelessWidget {
  final Future<List<User>>? usersFuture;
  const _PeopleList({required this.usersFuture});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<User>>(
      future: usersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No users found.",
              style: TextStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          itemCount: snapshot.data!.length,
          itemBuilder: (c, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: ListTile(
                leading: Avatar(user: snapshot.data![i], radius: 24),
                title: Text(
                  snapshot.data![i].displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DesignTokens.textPrimaryDark
                        : DesignTokens.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "@${snapshot.data![i].username}",
                  style: TextStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapLayer extends StatelessWidget {
  final MapController mapController;
  final List<Resource> resources;
  final PageController pageController;
  final bool isDark;

  const _MapLayer({
    required this.mapController,
    required this.resources,
    required this.pageController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
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
          // Switch to Dark Matter tiles in Dark Mode
          urlTemplate: isDark
              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
              : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.safespace', // Best practice
        ),
        MarkerLayer(
          markers: resources.map((resource) {
            return Marker(
              point: LatLng(resource.latitude, resource.longitude),
              width: 50,
              height: 50,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  mapController.move(
                    LatLng(resource.latitude, resource.longitude),
                    15,
                  );
                  final index = resources.indexOf(resource);
                  if (index != -1) {
                    pageController.animateToPage(
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

class _ResourcesOverlay extends StatelessWidget {
  final ResourceCategory? selectedCategory;
  final Function(ResourceCategory?) onCategorySelected;
  final List<Resource> resources;
  final PageController pageController;
  final MapController mapController;
  final BuildContext context;

  const _ResourcesOverlay({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.resources,
    required this.pageController,
    required this.mapController,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResourceFilters(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        ),

        const Spacer(),

        // Resource Carousel
        if (resources.isNotEmpty)
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: pageController,
              itemCount: resources.length,
              onPageChanged: (index) {
                final r = resources[index];
                mapController.move(LatLng(r.latitude, r.longitude), 15);
              },
              itemBuilder: (context, index) {
                return ResourceCarouselCard(
                  resource: resources[index],
                  onTap: () => _showResourceDetails(resources[index]),
                );
              },
            ),
          ),

        // Spacer for Bottom Nav
        const SizedBox(height: 100),
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
