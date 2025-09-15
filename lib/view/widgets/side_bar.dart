import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/media_query_values.dart';
import '../../providers/auth_provider.dart';

class SideBarMenuItem {
  final String title;
  final IconData icon;
  final String? routeName;
  final List<SideBarMenuItem> subItems;
  final VoidCallback? onTap;
  final Color? color;
  final Color? bgColor;

  SideBarMenuItem({
    required this.title,
    required this.icon,
    this.routeName,
    this.subItems = const [],
    this.onTap,
    this.color,
    this.bgColor,
  });
}

class SideBar extends StatefulWidget {
  final ValueChanged<String> onItemSelected;
  final String selectedRouteName;
  final bool isExpanded;
  final VoidCallback onToggle;

  const SideBar({
    super.key,
    required this.onItemSelected,
    required this.selectedRouteName,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final Map<String, bool> _expansionState = {};

  final List<SideBarMenuItem> _menuItems = [
    SideBarMenuItem(title: 'dashboard'.tr(), icon: Icons.data_exploration_rounded, routeName: '/dashboard'),
    SideBarMenuItem(title: 'inventory'.tr(), icon: Icons.inventory, routeName: '/inventory'),
    SideBarMenuItem(title: 'sales'.tr(), icon: Icons.point_of_sale, routeName: '/sales'),
    SideBarMenuItem(title: 'orders'.tr(), icon: Icons.receipt_long, routeName: '/orders'),
    SideBarMenuItem(title: 'analytics'.tr(), icon: Icons.analytics, routeName: '/analytics'),
    SideBarMenuItem(
      title: 'people'.tr(),
      icon: Icons.people,
      routeName: '/people',
      subItems: [
        SideBarMenuItem(title: 'customers'.tr(), icon: Icons.person_outline, routeName: '/people/customers'),
        SideBarMenuItem(title: 'suppliers'.tr(), icon: Icons.local_shipping_outlined, routeName: '/people/suppliers'),
      ],
    ),
    SideBarMenuItem(
      title: 'shop'.tr(),
      icon: Icons.store,
      routeName: '/shop',
      subItems: [
        SideBarMenuItem(title: 'products'.tr(), icon: Icons.fastfood_outlined, routeName: '/shop/products'),
        SideBarMenuItem(title: 'categories'.tr(), icon: Icons.category_outlined, routeName: '/shop/categories'),
      ],
    ),
  ];

  final List<SideBarMenuItem> _bottomItems = [
    SideBarMenuItem(icon: Icons.print, title: 'print_barcode'.tr(), routeName: '/print-barcode'),
    SideBarMenuItem(icon: Icons.settings, title: 'settings'.tr(), routeName: '/settings', color: const Color.fromARGB(255, 241, 137, 17)),
  ];

  @override
  void initState() {
    super.initState();
    for (var item in _menuItems) {
      if (item.subItems.isNotEmpty) {
        _expansionState[item.routeName!] = item.subItems.any((sub) => sub.routeName == widget.selectedRouteName);
      }
    }
  }

  void _toggleExpansion(String routeName) {
    if (!widget.isExpanded) {
      widget.onToggle();
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _expansionState[routeName] = true;
        });
      });
    } else {
      setState(() {
        _expansionState[routeName] = !(_expansionState[routeName] ?? false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: widget.isExpanded ? 250 : 72,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: context.height * 0.05),
          _buildProfileSection(colorScheme),
          SizedBox(height: context.height * 0.05),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) => _buildMenuItem(_menuItems[index], colorScheme),
            ),
          ),
          ..._bottomItems.map((item) => _buildMenuItem(item, colorScheme)),
          _buildLogoutButton(colorScheme),
          const Divider(height: 20, indent: 12, endIndent: 12),
          _buildToggleButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMenuItem(SideBarMenuItem item, ColorScheme colorScheme) {
    if (item.subItems.isNotEmpty) {
      return _buildExpansionItem(item, colorScheme);
    }

    return _buildNavItem(
      icon: item.icon,
      label: item.title,
      isSelected: widget.selectedRouteName == item.routeName,
      onTap: item.routeName != null ? () => widget.onItemSelected(item.routeName!) : item.onTap,
      colorScheme: colorScheme,
      itemColor: item.color,
    );
  }

  Widget _buildExpansionItem(SideBarMenuItem item, ColorScheme colorScheme) {
    final isExpanded = _expansionState[item.routeName!] ?? false;
    final isParentSelected = widget.selectedRouteName.startsWith(item.routeName!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem(
          icon: item.icon,
          label: item.title,
          isSelected: isParentSelected,
          trailing: widget.isExpanded
              ? Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  size: 18,
                )
              : null,
          onTap: () => _toggleExpansion(item.routeName!),
          colorScheme: colorScheme,
        ),
        if (widget.isExpanded && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 8.0),
            child: Column(
              children: item.subItems.map((subItem) {
                return _buildNavItem(
                  icon: subItem.icon,
                  label: subItem.title,
                  isSelected: widget.selectedRouteName == subItem.routeName,
                  onTap: () => widget.onItemSelected(subItem.routeName!),
                  isSubItem: true,
                  colorScheme: colorScheme,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
    bool isSelected = false,
    bool isSubItem = false,
    Widget? trailing,
    Color? itemColor,
  }) {
    final color = itemColor ??
        (isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Tooltip(
        message: widget.isExpanded ? '' : label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected && !isSubItem ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: widget.isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: isSubItem ? 20 : 24),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: isSubItem ? 11 : 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ColorScheme colorScheme) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return InkWell(
      onTap: () => widget.onItemSelected('/profile'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: widget.isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Admin User',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.role ?? 'Admin',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return _buildNavItem(
      icon: Icons.logout,
      label: 'logout'.tr(),
      itemColor: const Color.fromARGB(255, 241, 43, 17),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('logout'.tr()),
            content: Text('logout_confirmation'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pop(dialogContext);
                },
                child: Text('logout'.tr()),
              ),
            ],
          ),
        );
      },
      colorScheme: colorScheme,
    );
  }

  Widget _buildToggleButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IconButton(
        icon: Icon(
          widget.isExpanded ? Icons.chevron_left : Icons.chevron_right,
          color: colorScheme.onSurface.withOpacity(0.7),
          size: 24,
        ),
        onPressed: widget.onToggle,
        tooltip: widget.isExpanded ? 'minimize_sidebar'.tr() : 'expand_sidebar'.tr(),
      ),
    );
  }
}