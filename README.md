# Federico - Administrador de Gastos Personales

![Flutter](https://img.shields.io/badge/Flutter-3.38.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

**Federico** es una aplicación móvil moderna y completa para el seguimiento de gastos personales, diseñada con Flutter. Ofrece análisis avanzados, visualizaciones interactivas y una interfaz intuitiva para gestionar tus finanzas de manera eficiente.

## ✨ Características Principales

### 📊 Análisis Completo
- **Pantalla de Análisis con 3 Pestañas**:
  - **Distribución**: Gráfico de tarta/donut con desglose por categorías
  - **Tendencias**: Gráficos de barras y líneas mostrando evolución de gastos
  - **Reportes**: Comparación mes a mes y estadísticas detalladas

### 🎯 Gestión de Gastos
- Agregar, editar y eliminar gastos
- Categorización automática con iconos
- Descripción opcional para cada transacción
- Selección de fecha flexible
- **Formato de miles automático** al ingresar montos

### 🔍 Filtros Inteligentes
- **Filtros rápidos**: Hoy, Semana, Mes, Año
- Filtro por rango de fechas personalizado
- Filtro por categoría
- **Filtro por rango de monto** con slider interactivo

### 📈 Visualizaciones
- Gráfico de tarta/donut para distribución de gastos
- Gráfico de barras para tendencias mensuales
- Gráfico de líneas para evolución temporal
- Tarjetas de resumen rápido (Hoy, Semana, Mes)
- Indicadores de categoría principal

### 🎨 Interfaz Moderna
- Tema claro y oscuro con **toggle funcional**
- Diseño Material Design 3
- Animaciones suaves
- Espaciado consistente y profesional
- Responsive para diferentes tamaños de pantalla

## 🏗️ Arquitectura

### Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── models/
│   ├── expense.dart                   # Modelo de datos de gastos
│   └── expense.g.dart                 # Código generado por Hive
├── screens/
│   ├── dashboard_screen.dart          # Pantalla principal
│   ├── analytics_screen.dart          # Pantalla de análisis
│   ├── history_screen.dart            # Historial con filtros avanzados
│   └── add_edit_screen.dart           # Agregar/editar gastos
├── widgets/
│   ├── expense_card.dart              # Tarjeta de gasto individual
│   ├── expense_pie_chart.dart         # Gráfico de tarta
│   ├── trend_bar_chart.dart           # Gráfico de barras
│   ├── trend_line_chart.dart          # Gráfico de líneas
│   ├── category_breakdown_widget.dart # Desglose por categorías
│   ├── month_comparison_widget.dart   # Comparación mensual
│   └── category_dropdown.dart         # Selector de categorías
├── services/
│   └── database_service.dart          # Servicio de base de datos
└── theme/
    └── app_theme.dart                 # Configuración de temas
```

### Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Hive**: Base de datos local NoSQL de alto rendimiento
- **fl_chart**: Biblioteca de gráficos interactivos
- **intl**: Internacionalización y formato de fechas/números

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code con extensiones de Flutter
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tuusuario/gastofacil.git
cd gastofacil
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código de Hive**
```bash
flutter packages pub run build_runner build
```

4. **Ejecutar la aplicación**
```bash
# Para Windows
flutter run -d windows

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios
```

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3              # Base de datos local
  hive_flutter: ^1.1.0      # Integración de Hive con Flutter
  fl_chart: ^0.65.0         # Gráficos interactivos
  intl: ^0.18.1             # Internacionalización
  path_provider: ^2.1.1     # Acceso al sistema de archivos
  cupertino_icons: ^1.0.2   # Iconos de iOS

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  hive_generator: ^2.0.1    # Generador de código para Hive
  build_runner: ^2.4.6      # Constructor de código
```

## 💡 Características Técnicas

### Manejo de Errores
- Try-catch en todas las operaciones de base de datos
- Logging con `debugPrint` para debugging
- Valores por defecto seguros en caso de error
- Prevención de crashes

### Rendimiento
- Carga asíncrona de datos
- Indicadores de carga (shimmer/loading)
- Optimización de consultas a la base de datos
- Lazy loading en listas largas

### Experiencia de Usuario
- Pull-to-refresh en todas las pantallas
- Transiciones suaves entre pantallas
- Feedback visual en todas las acciones
- Estados vacíos informativos
- Validación de formularios en tiempo real

## 📱 Categorías de Gastos

La aplicación incluye 6 categorías predefinidas:

| Categoría | Icono | Color |
|-----------|-------|-------|
| Comida | 🍽️ | Rojo |
| Servicios | 💡 | Turquesa |
| Transporte | 🚗 | Amarillo |
| Ocio | 🎮 | Verde |
| Hogar | 🏠 | Rosa |
| Otros | 📦 | Lavanda |

## 🎯 Funcionalidades Destacadas

### 1. Formato de Miles Automático
Al ingresar montos, se agregan automáticamente puntos de miles:
- Entrada: `1000000` → Muestra: `1.000.000`
- Soporta decimales con coma: `1.500,50`

### 2. Análisis Avanzado
- **Distribución**: Visualiza qué porcentaje de tus gastos va a cada categoría
- **Tendencias**: Observa la evolución de tus gastos en los últimos 6 meses
- **Comparación**: Compara el mes actual con el anterior, categoría por categoría

### 3. Filtros Inteligentes
- Chips de período rápido para acceso instantáneo
- Slider de rango de montos con visualización en tiempo real
- Combinación de múltiples filtros simultáneos

### 4. Tema Claro/Oscuro
- Toggle funcional en la barra de navegación
- Persistencia del tema seleccionado
- Colores optimizados para ambos modos

## 🔧 Configuración Avanzada

### Personalizar Categorías

Edita `lib/models/expense.dart`:

```dart
static const List<String> categories = [
  'Tu Categoría',
  // ... más categorías
];

static const Map<String, int> categoryColors = {
  'Tu Categoría': 0xFFCOLOR,
  // ... más colores
};

static const Map<String, String> categoryIcons = {
  'Tu Categoría': '🎨',
  // ... más iconos
};
```

### Cambiar Formato de Moneda

Edita el formato en los archivos de pantalla:

```dart
final currencyFormat = NumberFormat.currency(
  symbol: '€',  // Cambiar símbolo
  decimalDigits: 2,
  locale: 'es_ES',  // Cambiar locale
);
```

## 📊 Métodos de Base de Datos

El `DatabaseService` ofrece métodos completos:

```dart
// CRUD básico
addExpense(Expense expense)
updateExpense(Expense expense)
deleteExpense(String id)
getExpenseById(String id)
getAllExpenses()

// Consultas por período
getExpensesByPeriod(String period)  // 'today', 'week', 'month', 'year'
getCurrentMonthExpenses()
getWeeklyExpenses()
getYearlyExpenses()

// Análisis
getCategoryTotals({DateTime? start, DateTime? end})
getCategoryPercentages()
getMonthlyTrend(int monthsBack)
compareMonths(DateTime month1, DateTime month2)

// Filtros
getFilteredExpenses({
  DateTime? startDate,
  DateTime? endDate,
  String? category,
  double? minAmount,
  double? maxAmount,
})
getExpensesByAmountRange(double min, double max)
```

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Compilación para Producción

### Android
```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

### Windows
```bash
flutter build windows --release
# Ejecutable en: build/windows/runner/Release/
```

### iOS
```bash
flutter build ios --release
```

## 📝 Roadmap

- [ ] Exportar datos a CSV/Excel
- [ ] Gráficos personalizables
- [ ] Presupuestos por categoría
- [ ] Recordatorios de gastos recurrentes
- [ ] Sincronización en la nube
- [ ] Múltiples cuentas/carteras
- [ ] Soporte para múltiples monedas
- [ ] Widgets para pantalla de inicio

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Federico**

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Comunidad de fl_chart por los gráficos
- Hive por la base de datos eficiente
- Todos los contribuidores de código abierto

---

**Nota**: Esta aplicación es para uso personal y educativo. No almacena datos en la nube y toda la información permanece en el dispositivo local.
