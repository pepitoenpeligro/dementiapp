import 'package:flutter/material.dart';

class MyBoxes extends StatefulWidget {
  @override
  _MyBoxesState createState() => _MyBoxesState();
}

class _MyBoxesState extends State<MyBoxes> {
  bool _isFocused1 = false;
  bool _isFocused2 = false;

  getSelectedBox() {
    return _isFocused1 == true ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isFocused1 = !_isFocused1;
              _isFocused2 = !_isFocused1;
            });
          },
          child: AnimatedContainer(
            width: _isFocused1 ? 200 : 100,
            height: _isFocused1 ? 200 : 100,
            color: Colors.blue,
            duration: Duration(milliseconds: 500),
          ),
        ),
        const SizedBox(
          width: 52,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isFocused2 = !_isFocused2;
              _isFocused1 = !_isFocused2;
            });
          },
          child: AnimatedContainer(
            width: _isFocused2 ? 200 : 100,
            height: _isFocused2 ? 200 : 100,
            color: Colors.red,
            duration: Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }
}
