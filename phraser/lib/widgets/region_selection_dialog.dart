import 'package:flutter/material.dart';
import 'package:phraser/util/preferences_util.dart';

class RegionSelectionDialog extends StatefulWidget {
  final String? currentRegion;
  final Function(String?) onRegionSelected;

  const RegionSelectionDialog({
    Key? key,
    this.currentRegion,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  _RegionSelectionDialogState createState() => _RegionSelectionDialogState();
}

class _RegionSelectionDialogState extends State<RegionSelectionDialog> {
  String? selectedRegion;

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.currentRegion;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Select Region',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRegionOption(
            context,
            'All Regions',
            'Show phrasers from all regions',
            Icons.public,
            Colors.blue,
            selectedRegion == null || selectedRegion == '',
            () => _selectRegion(''),
          ),
          const SizedBox(height: 8),
          _buildRegionOption(
            context,
            'Eastern',
            'Eastern region phrasers',
            Icons.location_on,
            Colors.green,
            selectedRegion == 'Eastern',
            () => _selectRegion('Eastern'),
          ),
          const SizedBox(height: 8),
          _buildRegionOption(
            context,
            'Western',
            'Western region phrasers',
            Icons.location_on,
            Colors.orange,
            selectedRegion == 'Western',
            () => _selectRegion('Western'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await PreferencesUtil.setSelectedRegion(selectedRegion ?? '');
            widget.onRegionSelected(selectedRegion);
            Navigator.of(context).pop();
          },
          child: Text(
            'Save',
            style: TextStyle(
              color: isDark ? Colors.blue[400] : Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _selectRegion(String region) {
    setState(() {
      selectedRegion = region.isEmpty ? '' : region;
    });
  }

  Widget _buildRegionOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.grey[700] : Colors.grey[100])
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.blue[400] : Colors.blue[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}