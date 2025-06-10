import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CronometroService extends ChangeNotifier {
  static final CronometroService _instance = CronometroService._internal();
  factory CronometroService() => _instance;
  CronometroService._internal() {
    _recuperarEstado();
  }

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  DateTime? _startTime;
  String? _sessaoId;
  String? _materiaNome;

  // Getters
  Duration get elapsed => _elapsed;
  bool get isRunning => _running;
  String? get sessaoId => _sessaoId;
  String? get materiaNome => _materiaNome;
  bool get hasActiveSession => _sessaoId != null;

  // Recuperar estado salvo
  Future<void> _recuperarEstado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _sessaoId = prefs.getString('cronometro_sessao_id');
      _materiaNome = prefs.getString('cronometro_materia_nome');
      final elapsedMs = prefs.getInt('cronometro_elapsed_ms') ?? 0;
      final wasRunning = prefs.getBool('cronometro_was_running') ?? false;
      final pauseTimeMs = prefs.getInt('cronometro_pause_time_ms');
      
      if (_sessaoId != null) {
        _elapsed = Duration(milliseconds: elapsedMs);
        
        if (wasRunning && pauseTimeMs != null) {
          // Estava rodando quando o app foi fechado
          // Calcular quanto tempo passou desde então
          final pauseTime = DateTime.fromMillisecondsSinceEpoch(pauseTimeMs);
          final tempoAdicional = DateTime.now().difference(pauseTime);
          
          // Adicionar o tempo que passou ao tempo decorrido
          _elapsed = _elapsed + tempoAdicional;
          
          // Recriar o startTime baseado no tempo total atual
          _startTime = DateTime.now().subtract(_elapsed);
          
          // Reiniciar o timer
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            _elapsed = DateTime.now().difference(_startTime!);
            notifyListeners();
            // Salvar estado a cada 5 segundos para não sobrecarregar
            if (_elapsed.inSeconds % 5 == 0) {
              _salvarEstado();
            }
          });
          
          _running = true;
          print('>> Cronômetro recuperado e reativado - Sessão: $_sessaoId, Tempo: $_elapsed');
        } else {
          // Estava pausado quando o app foi fechado
          _running = false;
          print('>> Cronômetro recuperado pausado - Sessão: $_sessaoId, Tempo: $_elapsed');
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('>> Erro ao recuperar estado do cronômetro: $e');
    }
  }

  // Salvar estado atual
  Future<void> _salvarEstado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_sessaoId != null) {
        await prefs.setString('cronometro_sessao_id', _sessaoId!);
        await prefs.setString('cronometro_materia_nome', _materiaNome ?? '');
        await prefs.setInt('cronometro_elapsed_ms', _elapsed.inMilliseconds);
        await prefs.setBool('cronometro_was_running', _running);
        
        if (_running) {
          // Se está rodando, salvar o timestamp atual
          await prefs.setInt('cronometro_pause_time_ms', DateTime.now().millisecondsSinceEpoch);
        } else {
          // Se está pausado, remover o timestamp
          await prefs.remove('cronometro_pause_time_ms');
        }
      } else {
        // Limpar estado salvo
        await _limparEstadoSalvo();
      }
    } catch (e) {
      print('>> Erro ao salvar estado do cronômetro: $e');
    }
  }

  Future<void> _limparEstadoSalvo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cronometro_sessao_id');
      await prefs.remove('cronometro_materia_nome');
      await prefs.remove('cronometro_elapsed_ms');
      await prefs.remove('cronometro_was_running');
      await prefs.remove('cronometro_pause_time_ms');
    } catch (e) {
      print('>> Erro ao limpar estado salvo: $e');
    }
  }

  void startCronometro({
    required String sessaoId,
    required String materiaNome,
    Duration? elapsedTime,
  }) {
    // Se já há uma sessão rodando para a mesma ID, não fazer nada
    if (_running && _sessaoId == sessaoId) return;
    
    // Se há uma sessão diferente rodando, parar primeiro
    if (_running && _sessaoId != sessaoId) {
      _timer?.cancel();
    }

    // Salvar a sessão anterior para comparação
    final sessaoAnterior = _sessaoId;
    
    _sessaoId = sessaoId;
    _materiaNome = materiaNome;
    
    // Se elapsedTime foi fornecido, usar ele
    // Se não foi fornecido E é uma sessão diferente da anterior, resetar para zero
    // Se não foi fornecido E é a mesma sessão da anterior, manter o tempo atual (recuperado do estado salvo)
    if (elapsedTime != null) {
      _elapsed = elapsedTime;
    } else if (sessaoAnterior == null || sessaoAnterior != sessaoId) {
      // Sessão diferente ou primeira vez - começar do zero
      _elapsed = Duration.zero;
    }
    // Caso contrário, manter o _elapsed atual (que foi recuperado do estado salvo)
    
    _startTime = DateTime.now().subtract(_elapsed);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
      // Salvar estado a cada 5 segundos para não sobrecarregar
      if (_elapsed.inSeconds % 5 == 0) {
        _salvarEstado();
      }
    });
    
    _running = true;
    _salvarEstado(); // Salvar imediatamente quando iniciar
    notifyListeners();
  }

  void updateElapsedTime(Duration newElapsed) {
    if (!hasActiveSession) return;
    
    _elapsed = newElapsed;
    _startTime = DateTime.now().subtract(_elapsed);
    _salvarEstado();
    notifyListeners();
  }

  void pauseCronometro() {
    if (!_running) return;
    
    _timer?.cancel();
    _running = false;
    _salvarEstado(); // Salvar estado pausado
    notifyListeners();
  }

  void resumeCronometro() {
    if (_running || !hasActiveSession) return;
    
    _startTime = DateTime.now().subtract(_elapsed);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
      // Salvar estado a cada 5 segundos
      if (_elapsed.inSeconds % 5 == 0) {
        _salvarEstado();
      }
    });
    
    _running = true;
    _salvarEstado(); // Salvar estado resumido
    notifyListeners();
  }

  void stopCronometro() {
    _timer?.cancel();
    _running = false;
    _sessaoId = null;
    _materiaNome = null;
    _elapsed = Duration.zero;
    _startTime = null;
    _limparEstadoSalvo(); // Limpar estado salvo
    notifyListeners();
  }

  void resetCronometro() {
    _timer?.cancel();
    _running = false;
    _elapsed = Duration.zero;
    if (_startTime != null) {
      _startTime = DateTime.now();
    }
    _salvarEstado(); // Salvar estado resetado
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:'
           '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
           '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // Método público para forçar salvamento imediato
  Future<void> salvarEstadoAgora() async {
    await _salvarEstado();
  }

  // Método público para inicializar e recuperar estado
  Future<void> inicializar() async {
    await _recuperarEstado();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _salvarEstado(); // Salvar estado final antes de descartar
    super.dispose();
  }
} 