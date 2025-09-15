import 'package:dashboard_template_dribbble/view/screens/pos/widgets/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colors.dart';

class RefundScreen extends StatefulWidget {
  final AwesomeDrawerBarController drawerController;

  const RefundScreen({Key? key, required this.drawerController}) : super(key: key);

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_filterTransactions);
  }

  void _loadTransactions() {
    setState(() => _isLoading = true);
    // Mock data - replace with your actual data source
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _transactions.addAll([
          Transaction(
            id: 'T1001',
            date: DateTime.now().subtract(const Duration(days: 1)),
            amount: 1250.50,
            items: 5,
            status: 'completed',
            paymentMethod: 'Cash',
            itemsDetails: [
              TransactionItem(
                name: 'Product 1',
                price: 250.00,
                quantity: 2,
                refunded: false,
              ),
              TransactionItem(
                name: 'Product 2',
                price: 750.50,
                quantity: 1,
                refunded: true,
              ),
            ],
          ),
          Transaction(
            id: 'T1002',
            date: DateTime.now().subtract(const Duration(days: 2)),
            amount: 875.25,
            items: 3,
            status: 'completed',
            paymentMethod: 'Credit Card',
            itemsDetails: [
              TransactionItem(
                name: 'Product 3',
                price: 300.00,
                quantity: 2,
                refunded: false,
              ),
            ],
          ),
        ]);
        _filteredTransactions = _transactions;
        _isLoading = false;
      });
    });
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        return transaction.id.toLowerCase().contains(query) ||
            transaction.paymentMethod.toLowerCase().contains(query) ||
            transaction.dateFormatted.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _processRefund(Transaction transaction, List<TransactionItem> itemsToRefund) {
    final refundAmount = itemsToRefund.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction: ${transaction.id}'),
            Text('Refund Amount: Rs. ${refundAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text('Payment Method: ${transaction.paymentMethod}'),
            if (transaction.paymentMethod == 'Credit Card')
              const Text('Note: Credit card refunds may take 3-5 business days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Process refund logic here
              Navigator.pop(context);
              _showRefundSuccess(transaction, refundAmount);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }

  void _showRefundSuccess(Transaction transaction, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refund of Rs. ${amount.toStringAsFixed(2)} processed for Transaction ${transaction.id}'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Update the transaction status
    setState(() {
      for (var item in transaction.itemsDetails) {
        if (item.refunded == false) {
          item.refunded = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refunds'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.drawerController.toggle?.call(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
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
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredTransactions.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text('No transactions found'),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return _buildTransactionCard(transaction, theme);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction #${transaction.id}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rs. ${transaction.amount.toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(transaction.dateFormatted),
            Text('${transaction.items} items • ${transaction.paymentMethod}'),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...transaction.itemsDetails.map((item) => _buildItemRow(item, theme)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showRefundDialog(transaction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Process Refund'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(TransactionItem item, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: item.refunded,
            onChanged: null, // Disabled - only changed through refund process
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (item.refunded) return Colors.green;
              return theme.disabledColor;
            }),
          ),
          Expanded(
            child: Text(
              item.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: item.refunded ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '${item.quantity} x Rs. ${item.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 10),
          Text(
            'Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: item.refunded ? Colors.green : primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(Transaction transaction) {
    final refundableItems = transaction.itemsDetails.where((item) => !item.refunded).toList();
    
    if (refundableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items available for refund in this transaction')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Items to Refund - ${transaction.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: refundableItems.length,
            itemBuilder: (context, index) {
              final item = refundableItems[index];
              return CheckboxListTile(
                title: Text(item.name),
                subtitle: Text('Rs. ${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                value: item.selectedForRefund,
                onChanged: (value) {
                  setState(() {
                    item.selectedForRefund = value ?? false;
                  });
                },
                secondary: Text(
                  'Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final selectedItems = refundableItems.where((item) => item.selectedForRefund).toList();
              if (selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one item to refund')),
                );
                return;
              }
              Navigator.pop(context);
              _processRefund(transaction, selectedItems);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final int items;
  final String status;
  final String paymentMethod;
  final List<TransactionItem> itemsDetails;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.items,
    required this.status,
    required this.paymentMethod,
    required this.itemsDetails,
  });

  String get dateFormatted => DateFormat('MMM dd, yyyy - hh:mm a').format(date);
}

class TransactionItem {
  final String name;
  final double price;
  final int quantity;
  bool refunded;
  bool selectedForRefund;

  TransactionItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.refunded = false,
    this.selectedForRefund = false,
  });
}