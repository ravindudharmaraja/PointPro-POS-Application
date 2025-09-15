import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../../providers/category_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(),
      child: const _CategoriesScreenContent(),
    );
  }
}

class _CategoriesScreenContent extends StatefulWidget {
  const _CategoriesScreenContent();

  @override
  State<_CategoriesScreenContent> createState() => _CategoriesScreenContentState();
}

class _CategoriesScreenContentState extends State<_CategoriesScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const Header(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme),
                      const SizedBox(height: 20),
                      _buildSearchBar(theme),
                      const SizedBox(height: 20),
                      _buildTable(theme, provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category List',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Add Category
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or ID',
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTable(ThemeData theme, CategoryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    if (provider.categories.isEmpty) {
      return Text(
        "No categories found.",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTableHeader(theme),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.scaffoldBackgroundColor.withOpacity(0.4),
                    ),
                    columns: _buildColumns(theme),
                    rows: provider.categories.map((category) {
                      return DataRow(
                        cells: [
                          DataCell(Text(category.id.toString())),
                          DataCell(
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.dividerColor,
                              backgroundImage: NetworkImage(category.thumbnail),
                              onBackgroundImageError: (_, __) {},
                              child: category.thumbnail.isEmpty
                                  ? Icon(Icons.image,
                                      color: theme.colorScheme.onSurfaceVariant)
                                  : null,
                            ),
                          ),
                          DataCell(Text(category.name)),
                          DataCell(Text(category.parentCategoryName ?? 'N/A')),
                          DataCell(Text('${category.totalProducts}')),
                          DataCell(
                            PopupMenuButton<String>(
                              onSelected: (value) {},
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Showing 1 to ${provider.categories.length} entries",
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              Row(
                children: [
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.chevron_left,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text("Page 1 of 1", style: theme.textTheme.bodySmall),
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Print'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns(ThemeData theme) {
    TextStyle headerStyle = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
    );

    return [
      DataColumn(label: Text('ID', style: headerStyle)),
      DataColumn(label: Text('Image', style: headerStyle)),
      DataColumn(label: Text('Name', style: headerStyle)),
      DataColumn(label: Text('Parent', style: headerStyle)),
      DataColumn(label: Text('Number of Products', style: headerStyle)),
      DataColumn(label: Text('Action', style: headerStyle)),
    ];
  }
}
