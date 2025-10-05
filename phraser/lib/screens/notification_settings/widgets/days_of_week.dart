import 'package:flutter/material.dart';
import 'package:phraser/util/colors.dart';

class DaysOfWeekWidget extends StatefulWidget {

  const DaysOfWeekWidget({Key? key, this.onDaysChanged, required this.currentDaysList}) : super(key: key);

  @override
  _DaysOfWeekWidgetState createState() => _DaysOfWeekWidgetState();

   final Function(List<bool> daysList)? onDaysChanged;
   final List<bool> currentDaysList;
}

class _DaysOfWeekWidgetState extends State<DaysOfWeekWidget> {
  List<bool> _selectedDays = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    if(widget.currentDaysList.isNotEmpty) {
      _selectedDays = widget.currentDaysList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark 
            ? kPrimaryColor.withOpacity(0.15)
            : kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? kPrimaryColor.withOpacity(0.3)
              : kPrimaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDayCircle("M", "Monday", 0, context),
          _buildDayCircle("T", "Tuesday", 1, context),
          _buildDayCircle("W", "Wednesday", 2, context),
          _buildDayCircle("T", "Thursday", 3, context),
          _buildDayCircle("F", "Friday", 4, context),
          _buildDayCircle("S", "Saturday", 5, context),
          _buildDayCircle("S", "Sunday", 6, context),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String dayLetter, String dayName, int index, BuildContext context) {
    final isSelected = _selectedDays[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
          widget.onDaysChanged?.call(_selectedDays);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected 
              ? kPrimaryColor 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? kPrimaryColor 
                : kPrimaryColor.withOpacity(isDark ? 0.4 : 0.25),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] 
              : null,
        ),
        child: Center(
          child: Text(
            dayLetter,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
