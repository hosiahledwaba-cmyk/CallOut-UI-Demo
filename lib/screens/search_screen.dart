// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/search_bar.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../data/search_repository.dart';
import '../models/resource.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchRepository _repository = SearchRepository();
  late Future<List<String>> _topicsFuture;
  late Future<List<Resource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _repository.getSuggestedTopics();
    _resourcesFuture = _repository.getNearbyResources();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      currentTabIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            GlassSearchBar(
              onChanged: (val) {},
            ), // TODO: Wire up API Search query
            const SizedBox(height: 20),
            Text(
              "Suggested Topics",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: _topicsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: snapshot.data!.map((t) => _buildChip(t)).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Nearby Resources",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Resource>>(
                future: _resourcesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final r = snapshot.data![index];
                      return _buildResourceCard(r);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: DesignTokens.glassWhite.withOpacity(0.5),
      elevation: 0,
    );
  }

  Widget _buildResourceCard(Resource r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassCard(
        child: ListTile(
          leading: Icon(
            r.type == 'police' ? Icons.local_police : Icons.place,
            color: DesignTokens.accentSecondary,
          ),
          title: Text(
            r.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(r.distance),
          trailing: const Icon(Icons.directions),
        ),
      ),
    );
  }
}
