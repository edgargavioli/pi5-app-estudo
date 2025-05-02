import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';

class CronogramaPage extends StatefulWidget {
  const CronogramaPage({super.key});

  @override
  State<CronogramaPage> createState() => _CronogramaPageState();
}

class _CronogramaPageState extends State<CronogramaPage> {
  // store events per day
  final Map<DateTime, List<String>> _events = {};

  // get normalized date (year-month-day)
  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      currentPage: 1,
      body: Column(
        children: [
          Text(
            'Cronograma',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(thickness: 1, height: 20),
          TableCalendar(
            eventLoader: (day) => _events[_normalize(day)] ?? [],
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF3a608f),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF73777F),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3a608f),
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF3a608f)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF3a608f)),
            ),
            calendarFormat: CalendarFormat.month,
          ),
          const Divider(thickness: 1, height: 20),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      'Selecione um dia para ver eventos.',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Eventos em ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...?_events[_normalize(_selectedDay!)]?.map((event) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFDDE0E6)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Text(event, style: const TextStyle(fontFamily: 'Poppins')),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ButtonWidget(
                text: 'Adicionar evento',
                onPressed: () async {
                  // full modal bottom sheet and dialogs logic to add 'evento' or 'estudo',
                  // exactly as in your earlier implementation but inside this onPressed.
                  final type = await showModalBottomSheet<String>(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Evento'),
                          leading: const Icon(Icons.event),
                          onTap: () => Navigator.pop(ctx, 'evento'),
                        ),
                        ListTile(
                          title: const Text('Estudo'),
                          leading: const Icon(Icons.school),
                          onTap: () => Navigator.pop(ctx, 'estudo'),
                        ),
                      ],
                    ),
                  );
                  if (type == null) return;
                  if (type == 'evento') {
                    // evento dialog
                    final nameCtl = TextEditingController();
                    TimeOfDay? start;
                    TimeOfDay? end;
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => StatefulBuilder(
                        builder: (ctx, setSt) => AlertDialog(
                          title: const Text('Novo Evento'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameCtl,
                                decoration: const InputDecoration(labelText: 'Nome do evento'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                                        if (t != null) setSt(() => start = t);
                                      },
                                      child: Text(start?.format(ctx) ?? 'Horário início'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                                        if (t != null) setSt(() => end = t);
                                      },
                                      child: Text(end?.format(ctx) ?? 'Horário fim'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                if (nameCtl.text.isNotEmpty && start != null && end != null) Navigator.pop(ctx, true);
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        final key = _normalize(_selectedDay!);
                        final desc = '${nameCtl.text} (${start!.format(context)} - ${end!.format(context)})';
                        _events[key] = (_events[key] ?? [])..add(desc);
                      });
                    }
                  } else if (type == 'estudo') {
                    // estudo dialog
                    final provas = ['Vestibular', 'ENEM', 'Outro'];
                    String selectedProva = provas[0];
                    final materias = ['Matemática', 'Português', 'Outra'];
                    String selectedMat = materias[0];
                    TimeOfDay? start;
                    TimeOfDay? end;
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => StatefulBuilder(
                        builder: (ctx, setSt) => AlertDialog(
                          title: const Text('Novo Estudo'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedProva,
                                items: provas.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                onChanged: (v) => setSt(() => selectedProva = v!),
                                decoration: const InputDecoration(labelText: 'Prova'),
                              ),
                              DropdownButtonFormField<String>(
                                value: selectedMat,
                                items: materias.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) => setSt(() => selectedMat = v!),
                                decoration: const InputDecoration(labelText: 'Matéria'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                                        if (t != null) setSt(() => start = t);
                                      },
                                      child: Text(start?.format(ctx) ?? 'Início'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                                        if (t != null) setSt(() => end = t);
                                      },
                                      child: Text(end?.format(ctx) ?? 'Fim'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                if (start != null && end != null) Navigator.pop(ctx, true);
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        final key = _normalize(_selectedDay!);
                        final desc = 'Estudo: $selectedProva / $selectedMat (${start!.format(context)}-${end!.format(context)})';
                        _events[key] = (_events[key] ?? [])..add(desc);
                      });
                    }
                  }
                },
                color: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}