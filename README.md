# Turco

App Flutter (Android) para la gestión de turnos de una peluquería mixta.
Primer examen parcial de *Programación para Dispositivos Móviles* (Ingeniería Informática, 3er año).

- **Application id:** `com.katherinealvarez.turco`
- **Nombre visible:** Turco
- **Flutter:** versión estable con Dart `^3.13.4` (anota aquí la salida de `flutter --version` con la que compilaste).
- **Arquitectura:** MVVM con `ChangeNotifier` y `ListenableBuilder` (sin paquetes externos de estado ni de almacenamiento).
- **Navegación:** `go_router` con `StatefulShellRoute.indexedStack`.

## Cómo ejecutar

```bash
flutter pub get
flutter run            # en un emulador o teléfono Android
flutter test           # pruebas de las reglas de negocio
```

## Generar el APK release

```bash
flutter build apk --release
# salida: build/app/outputs/flutter-apk/app-release.apk
```

El APK no se versiona (`build/` está ignorado): súbelo a **Releases** de GitHub.

## Estructura de carpetas

```
lib/
  main.dart                  MaterialApp.router, tema y localización (es)
  router/app_router.dart     rutas go_router + dependencias compartidas
  theme/app_theme.dart       ColorScheme claro/oscuro y temas de componentes (Poppins)
  models/                    Servicio, Estilista, Cliente, Turno y enums
  data/datos_prueba.dart     datos de prueba (fechas calculadas con DateTime.now())
  repositories/              SalonRepository: datos en memoria + reglas de negocio
  viewmodels/                ViewModels (ChangeNotifier) de cada pantalla
  screens/                   Agenda, Detalle, Formulario de turno, Clientes, Servicios, Estilistas
  widgets/                   widgets reutilizables (campos, chips de estado, diálogos...)
  utils/                     formato de fechas/precios, mensajes
assets/fonts/                Poppins
assets/images/               logo, imágenes de categoría y avatares
capturas/                    capturas reales de la app
entrega/                     material de entrega
```

## Rutas

`/agenda?estilista=ID` · `/clientes` · `/servicios` · `/estilistas` · `/turno/nuevo` (extra: `TurnoInicial`) · `/turno/:id` · `/turno/:id/editar`

## Notas

- La fuente Poppins SemiBold (peso 600) debe añadirse como `assets/fonts/Poppins-SemiBold.ttf` y apuntarse en `pubspec.yaml`
  (ahora el peso 600 usa Bold como reemplazo temporal).
- Las imágenes de `assets/images/categorias` y `avatares` son las del diseño; sustitúyelas por las exportadas del `.pen` conservando el nombre.
