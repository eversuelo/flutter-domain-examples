import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:one_hello_world/components/CounterButtons.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  int clickCounter = 0;
  //Status Manager
  void addCounter() {
    setState(() {
      _counter++;
      clickCounter++;
    });
  }

  void resetCounter() {
    setState(() {
      _counter = 0;
      clickCounter++;
    });
    
  }

  void subtractCounter() {
    setState(() {
      _counter--;
      clickCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Counter Screen',
          style: GoogleFonts.tektur(fontSize: 24, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Count:',
              style: GoogleFonts.tektur(fontSize: 24),
            ),
            Text(
              '$_counter',
              style: GoogleFonts.tektur(fontSize: 48),
            ),
            SizedBox(height: 16),
            Text(
              '${clickCounter==1?' Click':'Clicks'} $clickCounter',
              style: GoogleFonts.tektur(fontSize: 24),
            ),
          ],
        ),
      ),
      //3 Buttons
      floatingActionButton:Buttons(mainAxisAlignment:MainAxisAlignment.end,children: [
        CounterButton(onPressed: addCounter, iconData: Icons.add),
        CounterButton(onPressed: resetCounter, iconData: Icons.refresh),
        CounterButton(onPressed: subtractCounter, iconData: Icons.remove),
      ]),
    );  
  }
}
