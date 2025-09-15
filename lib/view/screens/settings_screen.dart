import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart'; // Your existing settings provider
import '../widgets/header.dart'; // Your header widget
import '../../providers/theme_provider.dart'; // Import the ThemeProvider file here

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Color> _colorPalette = [
    const Color(0xFF00C853), // Green
    const Color(0xFF2962FF), // Blue
    const Color(0xFFAA00FF), // Purple
    const Color(0xFFFFD600), // Amber
    const Color(0xFFFF6D00), // Orange
    const Color(0xFFD50000), // Red
    ThemeProvider.defaultPrimaryColor, // Also include the ThemeProvider default red
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: colorScheme.primary,
            ));
          }

          if (settingsProvider.error != null) {
            return Center(
                child: Text('Error: ${settingsProvider.error}',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colorScheme.error)));
          }

          if (settingsProvider.settings == null) {
            return Center(
                child: Text('No settings found.',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colorScheme.onSurface)));
          }

          return Column(
            children: [
              const Header(),
              _buildTabBar(theme, themeProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralSettings(settingsProvider, theme),
                    _buildLocalizationSettings(settingsProvider, theme),
                    _buildThemeSettings(theme, themeProvider),
                    _buildAboutSection(theme),
                  ],
                ),
              ),
              _buildActionButtons(settingsProvider, theme, themeProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: themeProvider.appPrimaryColor,
        isScrollable: true,
        tabs: [
          Tab(text: 'general'.tr()),
          Tab(text: 'localization'.tr()),
          Tab(text: 'appearance'.tr()),
          Tab(text: 'about'.tr()),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(SettingsProvider provider, ThemeData theme) {
    final settings = provider.settings!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildSettingsCard(
            title: 'system_information'.tr(),
            theme: theme,
            child: _buildTextField(
              label: 'system_title'.tr(),
              initialValue: settings.siteTitle,
              onChanged: (value) => provider.setSiteTitle(value),
              theme: theme,
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingsCard(
            title: 'brand_assets'.tr(),
            theme: theme,
            child: Row(
              children: [
                Expanded(
                    child: _buildImageUploadField(
                        label: 'system_logo'.tr(), theme: theme)),
                const SizedBox(width: 16),
                Expanded(
                    child:
                        _buildImageUploadField(label: 'small_logo'.tr(), theme: theme)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildImageUploadField(label: 'favicon'.tr(), theme: theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizationSettings(SettingsProvider provider, ThemeData theme) {
    final settings = provider.settings!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildSettingsCard(
            title: 'currency_configuration'.tr(),
            theme: theme,
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'currency_symbol'.tr(),
                    initialValue: settings.symbol,
                    onChanged: (value) => provider.setSymbol(value),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRadioGroup(
                    label: 'position'.tr(),
                    groupValue: settings.currencyPosition,
                    items: const ['Prefix', 'Suffix'],
                    onChanged: (value) => provider.setCurrencyPosition(value!),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingsCard(
            title: 'date_time_settings'.tr(),
            theme: theme,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRadioGroup(
                        label: 'direction'.tr(),
                        groupValue: settings.direction,
                        items: const ['ltr', 'rtl'],
                        onChanged: (value) => provider.setDirection(value!),
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRadioGroup(
                        label: 'show_time'.tr(),
                        groupValue: settings.dateWithTime,
                        items: const ['Enable', 'Disable'],
                        onChanged: (value) => provider.setDateWithTime(value!),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'date_format'.tr(),
                  value: settings.dateFormat,
                  items: const ['Y-m-d', 'd-m-Y', 'm-d-Y', 'Y/m/d', 'd/m/Y'],
                  onChanged: (value) => provider.setDateFormat(value!),
                  theme: theme,
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Language'.tr(),
                  value: settings.language,
                  items: const ['en', 'es', 'fr'], // Example languages
                  onChanged: (value) => provider.setLanguage(value!),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(ThemeData theme, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsCard(
                  title: 'theme_mode'.tr(),
                  theme: theme,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption(
                        label: 'light'.tr(),
                        isSelected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                        theme: theme,
                      ),
                      _buildThemeOption(
                        label: 'dark'.tr(),
                        isSelected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                        theme: theme,
                      ),
                      _buildThemeOption(
                        label: 'system'.tr(),
                        isSelected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingsCard(
                  title: 'primary_color'.tr(),
                  theme: theme,
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: _colorPalette
                          .map((color) => _buildColorOption(color, themeProvider))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildThemePreview(theme, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview(ThemeData theme, ThemeProvider themeProvider) {
    final primary = themeProvider.appPrimaryColor;
    return _buildSettingsCard(
      title: 'theme_preview'.tr(),
      theme: theme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.themeMode == ThemeMode.light
              ? Colors.grey[200]
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'action_button'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: _buildSettingsCard(
        title: 'developer_information'.tr(),
        theme: theme,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      label: 'company'.tr(),
                      value: 'CoreITDigital',
                      theme: theme),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      label: 'phone'.tr(), value: '0787379991', theme: theme),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      label: 'email'.tr(),
                      value: 'info@coreit.digital',
                      theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      SettingsProvider provider, ThemeData theme, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: provider.isSaving
                ? null
                : () {
                    provider.fetchSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Changes have been discarded.'),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              side: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ),
            child: Text('cancel'.tr()),
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: provider.isSaving
                ? null
                : () async {
                    final success = await provider.updateSettings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Settings saved successfully!'
                              : 'Failed to save settings: ${provider.error}'),
                          backgroundColor:
                              success ? Colors.green : theme.colorScheme.error,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.appPrimaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: provider.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('save_settings'.tr()),
          ),
        ],
      ),
    );
  }

  // === Helpers (same as before) ===

  Widget _buildSettingsCard(
      {required String title, required Widget child, ThemeData? theme}) {
    final cardColor = theme?.cardColor ?? Colors.grey[900];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        // border: Border.all(color: borderClr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.tr(),
              style: theme?.textTheme.titleMedium
                  ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant) ??
                  const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    ThemeData? theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tr(),
            style: theme?.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ) ??
                const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          style:
              TextStyle(color: theme?.colorScheme.onSurface ?? Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme?.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadField({required String label, ThemeData? theme}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.tr(),
          style: theme?.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              )),
      const SizedBox(height: 12),
      Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme?.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Icon(Icons.camera_alt, color: theme?.colorScheme.onSurface),
        ),
      ),
    ]);
  }

  Widget _buildRadioGroup({
    required String label,
    required String groupValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    ThemeData? theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tr(),
            style: theme?.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
        const SizedBox(height: 12),
        Row(
          children: items
              .map(
                (item) => Expanded(
                  child: RadioListTile<String>(
                    title: Text(item.tr(),
                        style: TextStyle(
                            color: theme?.colorScheme.onSurface ?? Colors.white)),
                    value: item,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: theme?.colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              )
              .toList(),
        )
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    ThemeData? theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tr(),
            style: theme?.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme?.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.tr(),
                          style: TextStyle(
                              color:
                                  theme?.colorScheme.onSurface ?? Colors.white)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }

  Widget _buildThemeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    ThemeData? theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme?.colorScheme.primary ?? Colors.blue
              : theme?.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme?.colorScheme.primary ?? Colors.blue
                : theme?.dividerColor ?? Colors.grey,
          ),
        ),
        child: Text(
          label.tr(),
          style: TextStyle(
            color: isSelected
                ? theme?.colorScheme.onPrimary
                : theme?.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, ThemeProvider themeProvider) {
    bool isSelected = color == themeProvider.appPrimaryColor;
    return GestureDetector(
      onTap: () => themeProvider.setPrimaryColor(color),
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required String label, required String value, ThemeData? theme}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(label.tr(),
              style: theme?.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  )),
        ),
        Expanded(
          flex: 2,
          child: Text(value,
              style: theme?.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  )),
        ),
      ],
    );
  }
}
