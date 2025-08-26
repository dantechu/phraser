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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDayCircle("M", "Monday", 0),
        _buildDayCircle("T", "Tuesday", 1),
        _buildDayCircle("W", "Wednesday", 2),
        _buildDayCircle("T", "Thursday", 3),
        _buildDayCircle("F", "Friday", 4),
        _buildDayCircle("S", "Saturday", 5),
        _buildDayCircle("S", "Sunday", 6),
      ],
    );
  }

  Widget _buildDayCircle(String dayLetter, String dayName, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
          widget.onDaysChanged?.call(_selectedDays);
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedDays[index] ? Colors.lightBlue : Colors.grey,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLetter,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
