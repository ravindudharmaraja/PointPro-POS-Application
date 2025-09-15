import 'package:dashboard_template_dribbble/view/screens/pos/widgets/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class POSCustomersScreen extends StatefulWidget {
  final AwesomeDrawerBarController drawerController;

  const POSCustomersScreen({super.key, required this.drawerController});

  @override
  State<POSCustomersScreen> createState() => _POSCustomersScreenState();
}

class _POSCustomersScreenState extends State<POSCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  bool _showAddCustomerForm = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  void _loadCustomers() {
    setState(() => _isLoading = true);
    // Mock data - replace with your actual data source
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _customers = [
          Customer(
            id: 'C1001',
            name: 'John Doe',
            phone: '+1 555-123-4567',
            email: 'john.doe@example.com',
            address: '123 Main St, New York',
            joinDate: DateTime.now().subtract(const Duration(days: 120)),
            totalPurchases: 12,
            totalSpent: 4500.75,
          ),
          Customer(
            id: 'C1002',
            name: 'Jane Smith',
            phone: '+1 555-987-6543',
            email: 'jane.smith@example.com',
            address: '456 Oak Ave, Los Angeles',
            joinDate: DateTime.now().subtract(const Duration(days: 90)),
            totalPurchases: 8,
            totalSpent: 3200.50,
          ),
          Customer(
            id: 'C1003',
            name: 'Robert Johnson',
            phone: '+1 555-456-7890',
            email: 'robert.j@example.com',
            address: '789 Pine Rd, Chicago',
            joinDate: DateTime.now().subtract(const Duration(days: 60)),
            totalPurchases: 5,
            totalSpent: 1875.25,
          ),
        ];
        _filteredCustomers = _customers;
        _isLoading = false;
      });
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.toLowerCase().contains(query) ||
            customer.email.toLowerCase().contains(query) ||
            customer.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleAddCustomerForm() {
    setState(() {
      _showAddCustomerForm = !_showAddCustomerForm;
      if (!_showAddCustomerForm) {
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _addressController.clear();
      }
    });
  }

  void _addCustomer() {
    if (_formKey.currentState!.validate()) {
      final newCustomer = Customer(
        id: 'C${1000 + _customers.length + 1}',
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        joinDate: DateTime.now(),
        totalPurchases: 0,
        totalSpent: 0.0,
      );

      setState(() {
        _customers.add(newCustomer);
        _filterCustomers();
        _toggleAddCustomerForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer ${newCustomer.name} added successfully')),
      );
    }
  }

  void _showCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCustomerDetailRow('Customer ID', customer.id),
              _buildCustomerDetailRow('Phone', customer.phone),
              _buildCustomerDetailRow('Email', customer.email),
              _buildCustomerDetailRow('Address', customer.address),
              _buildCustomerDetailRow('Member Since', customer.formattedJoinDate),
              const SizedBox(height: 16),
              const Divider(),
              _buildCustomerDetailRow('Total Purchases', customer.totalPurchases.toString()),
              _buildCustomerDetailRow('Total Spent', 'Rs. ${customer.totalSpent.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditCustomerForm(customer);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditCustomerForm(Customer customer) {
    _nameController.text = customer.name;
    _phoneController.text = customer.phone;
    _emailController.text = customer.email;
    _addressController.text = customer.address;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildCustomerForm(isEditing: true, customer: customer),
      ),
    );
  }

  void _updateCustomer(Customer customer) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        customer.name = _nameController.text;
        customer.phone = _phoneController.text;
        customer.email = _emailController.text;
        customer.address = _addressController.text;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer ${customer.name} updated successfully')),
      );
    }
  }

  void _deleteCustomer(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customers.remove(customer);
                _filterCustomers();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer ${customer.name} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.drawerController.toggle?.call(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddCustomerForm,
        child: Icon(_showAddCustomerForm ? Icons.close : Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (_showAddCustomerForm) _buildCustomerForm(),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredCustomers.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          'No customers found',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return _buildCustomerCard(customer, theme);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildCustomerForm({bool isEditing = false, Customer? customer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Edit Customer' : 'Add New Customer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email address';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEditing ? () => _updateCustomer(customer!) : _addCustomer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isEditing ? 'Update Customer' : 'Add Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.2),
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(customer.phone),
            Text(
              'Rs. ${customer.totalSpent.toStringAsFixed(2)} • ${customer.totalPurchases} purchases',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showCustomerActions(customer),
        ),
        onTap: () => _showCustomerDetails(customer),
      ),
    );
  }

  void _showCustomerActions(Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Customer'),
            onTap: () {
              Navigator.pop(context);
              _showEditCustomerForm(customer);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Customer', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteCustomer(customer);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('View Purchase History'),
            onTap: () {
              Navigator.pop(context);
              // Implement purchase history view
            },
          ),
        ],
      ),
    );
  }
}

class Customer {
  String id;
  String name;
  String phone;
  String email;
  String address;
  DateTime joinDate;
  int totalPurchases;
  double totalSpent;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.joinDate,
    required this.totalPurchases,
    required this.totalSpent,
  });

  String get formattedJoinDate => DateFormat('MMM dd, yyyy').format(joinDate);
}