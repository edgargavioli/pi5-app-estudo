import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'dart:async';
// removed ScaffoldWidget import to use simple Scaffold

class EstudosPage extends StatefulWidget {
  const EstudosPage({Key? key}) : super(key: key);
  @override
  State<EstudosPage> createState() => _EstudosPageState();
}

class _EstudosPageState extends State<EstudosPage> {
  String? _selectedVest;
  // Topic selection
  String? _selectedTopic;
  final List<String> _topics = [
    'Matemática',
    'Física',
    'Química',
    'Biologia',
    'História',
    'Geografia',
  ];

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_running) {
      // debug: timer start
      print('>> _startTimer() chamado');
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        // each tick, increment and redraw
        setState(() {
          _elapsed += const Duration(seconds: 1);
          print('>> tick: $_elapsed');
        });
      });
      setState(() {
        _running = true;
      });
    }
  }

  void _pauseTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
    });
  }

  void _pickTopic() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          children:
              _topics.map((topic) {
                return ListTile(
                  title: Text(topic),
                  onTap: () => Navigator.pop(context, topic),
                );
              }).toList(),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _selectedTopic = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                top: 10,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // back arrow
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Vestibular dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedVest,
                    isExpanded: true,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF191C20),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Prova',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Vestibular',
                        child: Text('Vestibular'),
                      ),
                      DropdownMenuItem(value: 'ENEM', child: Text('ENEM')),
                      DropdownMenuItem(value: 'FUVEST', child: Text('FUVEST')),
                    ],
                    onChanged: (v) => setState(() => _selectedVest = v),
                  ),
                  const SizedBox(height: 16),
                  // Topic dropdown styled like Prova dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTopic,
                    isExpanded: true,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF191C20),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Matéria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      prefixIcon: const Icon(Icons.menu_book),
                    ),
                    items:
                        _topics
                            .map(
                              (topic) => DropdownMenuItem(
                                value: topic,
                                child: Text(topic),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedTopic = v),
                  ),
                  const SizedBox(height: 32),
                  // session time
                  Center(
                    child: Text(
                      'Tempo de sessão',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      // display elapsed timer with hours, minutes and seconds
                      '${_elapsed.inHours.toString().padLeft(2, '0')}:'
                      '${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
                      '${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Seu último recorde foi:',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 0),
                        const Icon(
                          Icons.local_fire_department,
                          size: 24,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 0),
                        Text(
                          '02:48:33',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  // controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Pause button: visible when running, else gray
                      ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shadowColor: Colors.black26,
                          backgroundColor:
                              _running
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                          minimumSize: const Size(85, 85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.pause,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 22),
                      // Play button: visible when paused, else gray
                      ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shadowColor: Colors.black26,
                          backgroundColor:
                              !_running
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                          minimumSize: const Size(85, 85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 22),
                      // Reset button: resets and stops timer
                      ElevatedButton(
                        onPressed: _resetTimer,
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          shadowColor: Colors.black26,
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          minimumSize: const Size(85, 85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 160),
                  if (!_running && _elapsed > Duration.zero)
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: FloatingActionButton(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) => FractionallySizedBox(
                                heightFactor: 0.85,
                                child: SaveSessionSheet(elapsedTime: _elapsed),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A placeholder bottom sheet for saving a session.
class SaveSessionSheet extends StatelessWidget {
  final Duration elapsedTime;
  const SaveSessionSheet({Key? key, required this.elapsedTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = '${elapsedTime.inHours.toString().padLeft(2, '0')}:'
        '${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';
    // For the progress indicator, assuming 3 hours is the goal
    double progressValue = elapsedTime.inSeconds / (3 * 60 * 60);
    if (progressValue > 1.0) progressValue = 1.0;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Main session info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                // Left side: Vestibular + topic
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.article, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Vestibular',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.menu_book, size: 20),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Matemática',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Números primos',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side: progress ring
                Expanded(
                  flex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Meta',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        '03h00m',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 6,
                              color: Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Metrics card with equal-width columns
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                // Sequência renovada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '57',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sequência renovada',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Nível atual
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      SizedBox(height: 4),
                      Text(
                        '25',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nível atual',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Ganho de XP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Colors.yellow, size: 28),
                      SizedBox(height: 4),
                      Text(
                        '+50',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ganho de XP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Questions answered toggle and fields
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Exercícios realizados no estudo',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Questões respondidas input styled like other pages
                SizedBox(
                  width: 300,
                  height: 56,
                  child: InputWidget(
                    labelText: 'Quantidade de questões respondidas',
                    hintText: '',
                    controller: TextEditingController(),
                  ),
                ),
                const SizedBox(height: 16),
                // Questões acertadas input styled like other pages
                SizedBox(
                  width: 300,
                  height: 56,
                  child: InputWidget(
                    labelText: 'Quantidade de questões acertadas',
                    hintText: '',
                    controller: TextEditingController(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 40, // added fixed height
              child: ButtonWidget(
                text: 'Salvar',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                color: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
