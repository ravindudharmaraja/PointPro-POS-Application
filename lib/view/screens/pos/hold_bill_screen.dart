import 'package:dashboard_template_dribbble/view/screens/pos/widgets/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class HoldBillScreen extends StatefulWidget {
  final AwesomeDrawerBarController drawerController;

  const HoldBillScreen({super.key, required this.drawerController});

  @override
  State<HoldBillScreen> createState() => _HoldBillScreenState();
}

class _HoldBillScreenState extends State<HoldBillScreen> {
  bool _maintenanceMode = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _heldBills = [];
  List<Map<String, dynamic>> _filteredBills = [];

  @override
  void initState() {
    super.initState();
    _loadHeldBills();
    _searchController.addListener(_filterBills);
  }

  void _loadHeldBills() {
    // Mock data - replace with your actual data source
    setState(() {
      _heldBills = [
        {
          'id': 'B1001',
          'customer': 'Walk-in Customer',
          'amount': 1250.50,
          'time': '10:30 AM',
          'date': '2023-06-15',
          'status': 'held', // held, recalled, completed
          'items': 5,
        },
        {
          'id': 'B1002',
          'customer': 'John Doe',
          'amount': 875.25,
          'time': '11:45 AM',
          'date': '2023-06-15',
          'status': 'recalled',
          'items': 3,
        },
        {
          'id': 'B1003',
          'customer': 'Jane Smith',
          'amount': 2100.75,
          'time': '02:15 PM',
          'date': '2023-06-14',
          'status': 'held',
          'items': 8,
        },
      ];
      _filteredBills = _heldBills;
    });
  }

  void _filterBills() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBills = _heldBills.where((bill) {
        return bill['id'].toLowerCase().contains(query) ||
            bill['customer'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleMaintenanceMode() {
    setState(() {
      _maintenanceMode = !_maintenanceMode;
      if (_maintenanceMode) {
        // Add any maintenance mode specific logic here
      }
    });
  }

  void _recallBill(String billId) {
    setState(() {
      _heldBills = _heldBills.map((bill) {
        if (bill['id'] == billId) {
          return {...bill, 'status': 'recalled'};
        }
        return bill;
      }).toList();
      _filterBills();
    });
    // Add your actual recall logic here
  }

  void _completeBill(String billId) {
    setState(() {
      _heldBills = _heldBills.map((bill) {
        if (bill['id'] == billId) {
          return {...bill, 'status': 'completed'};
        }
        return bill;
      }).toList();
      _filterBills();
    });
    // Add your actual complete logic here
  }

  void _deleteBill(String billId) {
    setState(() {
      _heldBills.removeWhere((bill) => bill['id'] == billId);
      _filterBills();
    });
    // Add your actual delete logic here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hold Bills'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.drawerController.toggle?.call(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _maintenanceMode ? Icons.lock_open : Icons.lock_outline,
              color: _maintenanceMode ? Colors.red : null,
            ),
            onPressed: _toggleMaintenanceMode,
            tooltip: _maintenanceMode ? 'Exit Maintenance' : 'Maintenance Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bills...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (_maintenanceMode)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'MAINTENANCE MODE',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _filteredBills.isEmpty
                ? const Center(
                    child: Text('No held bills found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = _filteredBills[index];
                      return _buildBillCard(bill, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill, ThemeData theme) {
    final statusColor = bill['status'] == 'held'
        ? Colors.orange
        : bill['status'] == 'recalled'
            ? Colors.blue
            : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${bill['id']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bill['status'].toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bill['customer'],
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bill['items']} items',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Rs. ${bill['amount'].toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${bill['date']} • ${bill['time']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (bill['status'] == 'held') ...[
                  OutlinedButton(
                    onPressed: () => _recallBill(bill['id']),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Recall'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: () => _completeBill(bill['id']),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Complete'),
                ),
                if (_maintenanceMode) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBill(bill['id']),
                    tooltip: 'Delete Bill',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}