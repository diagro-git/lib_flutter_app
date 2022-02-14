<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://diagro.be/assets/img/diagro-logo.svg" width="400"></a></p>

<p align="center">
<img src="https://img.shields.io/badge/project-lib_flutter_app-yellowgreen" alt="Diagro flutter library">
<img src="https://img.shields.io/badge/type-library-informational" alt="Diagro service">
<img src="https://img.shields.io/badge/php-8.0-blueviolet" alt="PHP">
<img src="https://img.shields.io/badge/laravel-8.67-red" alt="Laravel framework">
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

### V1.0.0

* **Feature**: login, company en logout screen and callbacks
* **Feature**: offline page when internet connection is lost
* **Feature**: DiagroApp class