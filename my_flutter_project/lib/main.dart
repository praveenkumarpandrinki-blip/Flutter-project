import 'package:flutter/material.dart';

void main() {
  runApp(const RecyclingApp());
}

const Color green = Color(0xFF168447);
const Color lightGreen = Color(0xFFE7F5EC);
const Color orange = Color(0xFFFF9800);
const Color blue = Color(0xFF2196F3);
const Color purple = Color(0xFF8E44AD);

class RecyclingApp extends StatelessWidget {
  const RecyclingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plastic Recycling Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class RecyclingRecord {
  final String id;
  String name;
  String material;
  double quantity;
  String location;
  DateTime date;
  bool recycled;

  RecyclingRecord({
    required this.id,
    required this.name,
    required this.material,
    required this.quantity,
    required this.location,
    required this.date,
    required this.recycled,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String searchQuery = '';
  String filter = 'All';

  final List<RecyclingRecord> records = [];

  double get totalCollected =>
      records.fold(0, (sum, item) => sum + item.quantity);

  double get totalRecycled => records
      .where((item) => item.recycled)
      .fold(0, (sum, item) => sum + item.quantity);

  double get totalPending => records
      .where((item) => !item.recycled)
      .fold(0, (sum, item) => sum + item.quantity);

  int get recycledCount => records.where((item) => item.recycled).length;

  List<RecyclingRecord> get filteredRecords {
    return records.where((record) {
      final matchesSearch =
          record.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              record.material.toLowerCase().contains(searchQuery.toLowerCase()) ||
              record.location.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter = filter == 'All' ||
          (filter == 'Recycled' && record.recycled) ||
          (filter == 'Pending' && !record.recycled);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboardPage(),
      recordsPage(),
      reportsPage(),
      aboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plastic Recycling',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add record',
            onPressed: () => showRecordDialog(),
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: pages[selectedIndex]),
      floatingActionButton: selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: () => showRecordDialog(),
              backgroundColor: green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Record'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.recycling_outlined),
            selectedIcon: Icon(Icons.recycling),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }

  Widget dashboardPage() {
  return RefreshIndicator(
    onRefresh: () async {
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );
      if (mounted) setState(() {});
    },
    child: ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Compact green welcome banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [green, Color(0xFF31A86A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.eco,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(height: 6),
              Text(
                'Make Every Piece Count!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track collected materials and monitor recycling progress.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Shorter dashboard cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: [
            statCard(
              'Total Collected',
              '${totalCollected.toStringAsFixed(1)} kg',
              Icons.inventory_2_outlined,
              blue,
            ),
            statCard(
              'Total Recycled',
              '${totalRecycled.toStringAsFixed(1)} kg',
              Icons.recycling,
              green,
            ),
            statCard(
              'Pending',
              '${totalPending.toStringAsFixed(1)} kg',
              Icons.pending_actions,
              orange,
            ),
            statCard(
              'Total Records',
              '${records.length}',
              Icons.description_outlined,
              purple,
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => selectedIndex = 1);
              },
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: 4),

        if (records.isEmpty)
          emptyState(
            'No Records Yet',
            'Add your first recycling record to get started.',
          )
        else
          ...records.take(4).map(recordTile),

        // Small space at the bottom
        const SizedBox(height: 10),
      ],
    ),
  );
}
  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
  Widget recordsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search name, material or location',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => searchQuery = ''),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: ['All', 'Recycled', 'Pending'].map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(item),
                  selected: filter == item,
                  onSelected: (_) => setState(() => filter = item),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filteredRecords.isEmpty
              ? emptyState(
                  'No Records Found',
                  records.isEmpty
                      ? 'Add a record to see it here.'
                      : 'Try changing your search or filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) =>
                      recordTile(filteredRecords[index]),
                ),
        ),
      ],
    );
  }

  Widget recordTile(RecyclingRecord record) {
    final statusColor = record.recycled ? green : orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                materialIcon(record.material),
                color: green,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${record.material} • ${record.location}'),
                  const SizedBox(height: 4),
                  Text(
                    '${record.quantity.toStringAsFixed(1)} kg • ${formatDate(record.date)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.recycled ? 'Recycled' : 'Pending',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') showRecordDialog(record: record);
                if (value == 'status') toggleStatus(record);
                if (value == 'delete') deleteRecord(record);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'status',
                  child: ListTile(
                    leading: const Icon(Icons.recycling),
                    title: Text(
                      record.recycled ? 'Mark Pending' : 'Mark Recycled',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData materialIcon(String material) {
    switch (material) {
      case 'Plastic':
        return Icons.recycling;
      case 'Paper':
        return Icons.description_outlined;
      case 'Metal':
        return Icons.build_outlined;
      case 'Glass':
        return Icons.wine_bar_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget reportsPage() {
    final materials = <String, double>{};

    for (final record in records) {
      materials[record.material] =
          (materials[record.material] ?? 0) + record.quantity;
    }

    final progress =
        totalCollected == 0 ? 0.0 : totalRecycled / totalCollected;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recycling Reports',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Review your collected and recycled materials.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recycling Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    height: 130,
                    width: 130,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: lightGreen,
                          color: green,
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${totalRecycled.toStringAsFixed(1)} kg recycled out of ${totalCollected.toStringAsFixed(1)} kg collected',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Material Breakdown',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (materials.isEmpty)
          emptyState(
            'No Report Data',
            'Your material breakdown will appear after you add records.',
          )
        else
          ...materials.entries.map((entry) {
            final ratio =
                totalCollected == 0 ? 0.0 : entry.value / totalCollected;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${entry.value.toStringAsFixed(1)} kg'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: green,
                      backgroundColor: lightGreen,
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget aboutPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 48,
          backgroundColor: lightGreen,
          child: Icon(Icons.eco, color: green, size: 54),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'Plastic Recycling Dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A simple application to record recyclable materials, track '
          'collection quantities, and monitor recycling progress.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
        const SizedBox(height: 24),
        aboutItem(
          Icons.add_circle_outline,
          'Add Records',
          'Record the material name, quantity and collection location.',
        ),
        aboutItem(
          Icons.search,
          'Search and Filter',
          'Find records and filter by recycled or pending status.',
        ),
        aboutItem(
          Icons.bar_chart,
          'View Reports',
          'See total quantities and a breakdown by material type.',
        ),
        aboutItem(
          Icons.edit_outlined,
          'Manage Records',
          'Edit, delete or update the recycling status of a record.',
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget aboutItem(IconData icon, String title, String description) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(icon, color: green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
  Widget emptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 65,
              color: green,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showRecordDialog({
    RecyclingRecord? record,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: record?.name ?? '',
    );

    final quantityController = TextEditingController(
      text: record == null ? '' : record.quantity.toString(),
    );

    final locationController = TextEditingController(
      text: record?.location ?? '',
    );

    String material = record?.material ?? 'Plastic';
    bool isRecycled = record?.recycled ?? false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, updateDialog) => AlertDialog(
            title: Text(
              record == null ? 'Add Record' : 'Edit Record',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity (kg)',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      validator: (value) {
                        final number = double.tryParse(value ?? '');

                        if (number == null || number <= 0) {
                          return 'Enter a quantity above zero';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: material,
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        'Plastic',
                        'Paper',
                        'Metal',
                        'Glass',
                        'Other',
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            material = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Already recycled'),
                      value: isRecycled,
                      onChanged: (value) {
                        updateDialog(() {
                          isRecycled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  setState(() {
                    if (record == null) {
                      records.insert(
                        0,
                        RecyclingRecord(
                          id: DateTime.now()
                              .microsecondsSinceEpoch
                              .toString(),
                          name: nameController.text.trim(),
                          material: material,
                          quantity: double.parse(
                            quantityController.text.trim(),
                          ),
                          location: locationController.text.trim(),
                          date: DateTime.now(),
                          recycled: isRecycled,
                        ),
                      );
                    } else {
                      record.name = nameController.text.trim();
                      record.material = material;
                      record.quantity = double.parse(
                        quantityController.text.trim(),
                      );
                      record.location =
                          locationController.text.trim();
                      record.recycled = isRecycled;
                    }
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        record == null
                            ? 'Record added successfully'
                            : 'Record updated successfully',
                      ),
                    ),
                  );
                },
                child: Text(
                  record == null ? 'Add' : 'Update',
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      quantityController.dispose();
      locationController.dispose();
    }
  }

  void toggleStatus(RecyclingRecord record) {
    setState(() {
      record.recycled = !record.recycled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          record.recycled
              ? 'Marked as recycled'
              : 'Marked as pending',
        ),
      ),
    );
  }

  Future<void> deleteRecord(RecyclingRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Record?'),
        content: Text('Delete "${record.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        records.removeWhere((item) => item.id == record.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record deleted'),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}