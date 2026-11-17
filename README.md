# MaintainerHandoff

> **«Que tu proyecto pueda continuar sin depender de tu memoria»**

![Android](https://img.shields.io/badge/Android-Offline--First-1D4ED8)
![Security](https://img.shields.io/badge/Secretos-Nunca%20almacenados-critical)
![Zero Telemetry](https://img.shields.io/badge/Telemetr%C3%ADa-0%25-success)

**MaintainerHandoff** ayuda a mantenedores de software libre a documentar todo lo necesario para ceder o compartir el mantenimiento de un repositorio sin depender de su memoria ni exponer credenciales.

---

## Características principales

- **Checklist estructurado de traspaso**: cubre *Repositorio y ramas*, *Builds y CI*, *Accesos y secretos (solo inventario, nunca claves)* y *Gobernanza y comunidad*.
- **Exportación `HANDOFF.md` y CSV**: genera documentación lista para añadir al repositorio y hoja de inventario.
- **Empaquetado ZIP seguro**: incluye `HANDOFF.md`, `checklist.csv` y `manifest.sha256`, bloqueando rutas con path traversal (`../../`) y excluyendo automáticamente archivos sensibles (`.env`, `.pem`, `.key`, `id_rsa`, `secrets.*`).
- **IA opcional BYOK (gratuita)**: desactivada por defecto.

---

## Seguridad y privacidad

- **Nunca almacena ni exporta secretos reales** (tokens, contraseñas o claves privadas).
- Persistencia local en SQLite, sin telemetría ni sincronización en la nube.

---

## Instalación y compilación local

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

---

## Documentación adicional

- [DEPENDENCIES.md](DEPENDENCIES.md) · [CONTRIBUTING.md](CONTRIBUTING.md)
