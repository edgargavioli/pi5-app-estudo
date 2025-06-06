# Guia de Troubleshooting - PI5 MS Mobile

## Problemas Comuns e Soluções

### 🚨 **Problema: Ícones Sumiram do App**

**Sintomas**:
- Ícones não aparecem na interface
- Espaços vazios onde deveriam estar os ícones
- App funciona mas sem elementos visuais

**Causa**: Problema com carregamento de fontes (GoogleFonts ou Material Icons)

**Soluções**:

1. **Verificar dependências**:
```bash
flutter pub get
```

2. **Limpar cache**:
```bash
flutter clean
flutter pub get
```

3. **Verificar pubspec.yaml**:
```yaml
dependencies:
  cupertino_icons: ^1.0.8  # Para ícones iOS
  google_fonts: ^6.2.1     # Para fontes personalizadas

flutter:
  uses-material-design: true  # IMPORTANTE para Material Icons
```

4. **Verificar imports**:
```dart
import 'package:flutter/material.dart';  // Para Icons.xxx
import 'package:flutter/cupertino.dart';  // Para CupertinoIcons.xxx
```

### 🚨 **Problema: AssetManifest.json não encontrado (Flutter Web)**

**Sintomas**:
```
Error while trying to load an asset: Flutter Web engine failed to fetch "assets/AssetManifest.json". HTTP request succeeded, but the server responded with HTTP status 404.
```

**Causa**: Problemas de cache ou build corrompido no Flutter Web

**Soluções**:

1. **Limpeza completa**:
```bash
flutter clean
flutter pub get
```

2. **Para Flutter Web especificamente**:
```bash
flutter clean
rm -rf build/web  # ou del build\web no Windows
flutter build web
```

3. **Verificar assets no pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/fonts/
```

### 🚨 **Problema: GoogleFonts não carrega**

**Sintomas**:
```
Error: google_fonts was unable to load font Roboto-Regular
Unable to load asset: "AssetManifest.json"
```

**Causa**: Problemas de conectividade ou cache do GoogleFonts

**Soluções**:

1. **Usar fallback para fontes locais** (já implementado):
```dart
// Em util.dart - versão híbrida
try {
  return GoogleFonts.getTextTheme(fontName, baseTheme);
} catch (e) {
  return _createLocalTextTheme(baseTheme, fontName);
}
```

2. **Adicionar fontes locais no pubspec.yaml**:
```yaml
flutter:
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins/Poppins-Regular.ttf
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto/static/Roboto-Regular.ttf
```

### 🚨 **Problema: API não responde**

**Sintomas**:
- Dados não carregam
- Erro de conexão
- Timeout

**Soluções**:

1. **Verificar backend**:
```bash
cd pi5-app-estudo/pi5_ms_provas
docker ps  # Verificar se containers estão rodando
docker-compose up -d  # Iniciar se necessário
```

2. **Testar API diretamente**:
```bash
curl http://localhost:3000/materias
curl http://localhost:3000/provas
curl http://localhost:3000/sessoes
```

3. **Verificar logs do backend**:
```bash
docker logs pi5_ms_provas-app-1
```

### 🚨 **Problema: Erro de Build/Compilação**

**Sintomas**:
- `flutter run` falha
- Erros de dependências
- Conflitos de versão

**Soluções**:

1. **Limpeza completa**:
```bash
flutter clean
flutter pub cache clean
flutter pub get
```

2. **Verificar versão do Flutter**:
```bash
flutter doctor
flutter upgrade  # Se necessário
```

3. **Resolver conflitos de dependências**:
```bash
flutter pub deps
flutter pub outdated
```

### 🚨 **Problema: Cronograma não mostra eventos**

**Sintomas**:
- Calendário aparece vazio
- Eventos não carregam
- Erro ao criar sessões

**Soluções**:

1. **Verificar dados no backend**:
```bash
# Testar se há dados
curl http://localhost:3000/materias
curl http://localhost:3000/provas
curl http://localhost:3000/sessoes
```

2. **Verificar logs do app**:
- Abrir DevTools no Flutter
- Verificar console para erros de API

3. **Recriar dados de teste**:
```bash
# No diretório do backend
node -e "
const s = {
  materiaId: 'ID_MATERIA_VALIDO',
  conteudo: 'Teste',
  topicos: ['Teste'],
  tempoInicio: new Date().toISOString()
};
fetch('http://localhost:3000/sessoes', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify(s)
}).then(r => r.json()).then(console.log);
"
```

## Comandos de Emergência

### **Reset Completo do Projeto**:
```bash
# 1. Limpar Flutter
flutter clean
flutter pub cache clean

# 2. Reinstalar dependências
flutter pub get

# 3. Reiniciar backend
cd ../pi5_ms_provas
docker-compose down
docker-compose up -d

# 4. Verificar se tudo está funcionando
docker ps
curl http://localhost:3000/materias
```

### **Verificação de Saúde do Sistema**:
```bash
# Flutter
flutter doctor -v

# Backend
docker ps
docker logs pi5_ms_provas-app-1

# API
curl -I http://localhost:3000/materias
```

### **Rebuild Completo**:
```bash
# Para Windows
flutter clean
Remove-Item -Recurse -Force build
flutter pub get
flutter build windows

# Para Web
flutter clean
Remove-Item -Recurse -Force build\web
flutter pub get
flutter build web
```

## Logs Importantes

### **Onde encontrar logs**:

1. **Flutter App**:
   - Console do VS Code/IDE
   - DevTools do Flutter
   - `flutter logs`

2. **Backend**:
   - `docker logs pi5_ms_provas-app-1`
   - `docker logs pi5_ms_provas-db-1`

3. **Banco de Dados**:
   - Conectar via cliente PostgreSQL
   - Verificar tabelas: `materias`, `provas`, `sessoes_estudo`

### **Comandos de Debug**:
```bash
# Verificar dependências
flutter pub deps

# Analisar código
flutter analyze

# Verificar performance
flutter run --profile

# Debug detalhado
flutter run --verbose
```

## Contatos de Emergência

- **Documentação Flutter**: https://docs.flutter.dev/
- **Troubleshooting TableCalendar**: https://pub.dev/packages/table_calendar
- **Docker Issues**: https://docs.docker.com/

---

**Última Atualização**: 26/05/2025 - Problemas de ícones e assets resolvidos 