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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
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
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
          widget.onDaysChanged?.call(_selectedDays);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                  : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
