# Travify

Este Trabajo de Fin de Grado presenta Travify, una aplicación para dispositivos móviles
desarrollada en Flutter, que permite una completa gestión económica del viaje de forma
sencilla, intuitiva y completamente funcional incluso, sin conexión a internet. 

Con una interfaz
clara y accesible, el usuario puede contabilizar los gastos e ingresos asociados, convertir divisas
a más de 30 monedas, establecer presupuestos personalizados y llevar un reporte detallado
del estado financiero de cada viaje.

---

## Funcionalidades principales

- Registro y gestión de gastos en diferentes divisas.
- Conversión automática entre monedas.
- Visualización de estadísticas y gráficas de gasto.
- Soporte multilingüe con traducciones fácilmente ampliables.
- Funcionamiento offline con almacenamiento local.

---

## 📱 Capturas de pantalla

<p float="left">
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/7c/ad/52/7cad52af-7d2f-5e97-4092-3544494a34f0/1_ger_ready.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/e6/97/00/e6970052-828f-79e4-37b7-2f535e85e2cd/2_home.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/3c/48/eb/3c48ebab-ea7e-684f-79ef-92995a50386e/3_expenses.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/d2/ba/f4/d2baf475-0088-4cdd-ee4d-b3248b0d140d/4_incomes.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/55/8e/d6/558ed68c-70d1-424e-c86d-de4b2f6786a5/4_changes.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/54/81/4c/54814ce7-4fe2-90b9-39aa-f72f08c22f17/5_change_form.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/32/80/16/32801674-eaeb-1355-b3e9-0fb0fa973f0a/6_graphs.png/400x800bb.png" width="200" />
  <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/66/cf/1b/66cf1b76-46d1-7d69-d71a-f96e012c1dfe/7_history.png/400x800bb.png" width="200" />
</p>

---

## 🚀 Instalación y ejecución

Sigue los pasos a continuación para instalar y ejecutar Travify en un entorno local:

### 1. Clona el repositorio

```bash
git clone https://github.com/crm107-ua/travify.git
```

### 2. Accede al directorio del proyecto

```bash
cd travify
```

### 3. Asegúrate de tener Flutter instalado

Si no tienes Flutter instalado, puedes seguir la [guía oficial de instalación](https://docs.flutter.dev/get-started/install).

### 4. Verifica tu entorno de Flutter

```bash
flutter doctor
```

Asegúrate de que no haya errores críticos antes de continuar.

### 5. Instala las dependencias

```bash
flutter pub get
```

### 6. Ejecuta la aplicación

Puedes ejecutar Travify en un emulador o dispositivo físico:

```bash
flutter run
```

---

## 🌐 Traducciones

La aplicación cuenta con soporte para múltiples idiomas. Las traducciones existentes se encuentran en la carpeta `assets/translations/`. Se pueden añadir nuevos idiomas fácilmente siguiendo el formato proporcionado.

---

## 🧩 Dependencias principales

- `flutter_bloc`: Gestión de estados reactiva.
- `sqflite`: Base de datos local SQLite.
- `easy_localization`: Internacionalización y traducción.
- `fl_chart`: Gráficas y estadísticas.
- `path_provider`: Acceso a rutas de almacenamiento.

Para ver todas las dependencias, revisa el archivo [`pubspec.yaml`](pubspec.yaml).

---

## 👨‍🎓 Autor

Este proyecto ha sido desarrollado por **Carlos Robles** como parte del Trabajo de Fin de Grado del Grado en Ingeniería Informática en la Universidad de Alicante.