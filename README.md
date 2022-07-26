<p align="center"><a href="https://www.diagro.be" target="_blank"><img src="https://diagro.be/assets/img/diagro-logo.svg" width="400"></a></p>

<p align="center">
<img src="https://img.shields.io/badge/project-lib_flutter_app-yellowgreen" alt="Diagro flutter library">
<img src="https://img.shields.io/badge/type-library-informational" alt="Diagro library">
</p>

## Beschrijving

Deze bibliotheek dient als basis voor alle Diagro apps die gemaakt worden met Flutter.

## Dependencies

<p><a href="https://github.com/diagro-git/lib_flutter_token"><img src="https://img.shields.io/badge/lib-flutter_token-informational" alt="Diagro token library"></a></p>


## Development

```yaml
lib_flutter_app:
    git:
      url: https://github.com/diagro-git/lib_flutter_app.git
      ref: ^1.0.0
```

### Configuration

Maak een **.env** file zoals onderstaand voorbeeld. De APP_ID is de ID van de frontend_applications table.

```dotenv
DIAGRO_SERVICE_AUTH_URL=auth.diagro.dev
APP_ID=1
```

## Changelog

### V1.7.0

* **Update**: device_info_plus package usage for tracking the user device ID.

### V1.6.0

* **Update**: Loading widget to show a loading spinner with optional text.

### V1.3.0

* **Update**: iOS tracking permission vereist bij opvragen van tracking ID

### V1.2.0

* **Feature**: AT token wordt niet meer external opgeslagen maar in de app. Login uit andere apps wordt gedaan door opzoeken van AT token aan de hand van de device UID

### V1.1.0

* **Feature**: api class met error handling 
* **Feature**: unauthorized en error screens
* **Feature**: standaard drawer

### V1.0.0

* **Feature**: login, company en logout screen and callbacks
* **Feature**: offline page when internet connection is lost
* **Feature**: DiagroApp class