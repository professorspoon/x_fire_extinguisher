# X_FireExtinguisher

Un recurso para FiveM que permite a los jugadores recoger y usar extintores encontrados por todo el mapa del juego.

## Características

- Recoge cualquier extintor encontrado en el mundo del juego
- Rendimiento optimizado con uso mínimo de recursos
- Soporte para los frameworks ESX y QBCore
- Selección automática del arma después de recoger el extintor
- Sistema de enfriamiento para prevenir abusos
- Notificaciones y TextUI personalizables
- Soporte multilingüe

## Instalación

1. Descarga el recurso
2. Colócalo en la carpeta de recursos de tu servidor
3. Añade `ensure X_FireExtinguisher` a tu server.cfg
4. Configura los ajustes en `configuration/config.lua` según tus preferencias

## Configuración

El script es altamente configurable a través del archivo `configuration/config.lua`:

- Selección de framework (ESX o QBCore)
- Versión de ESX (nueva o antigua)
- Configuración del tiempo de enfriamiento
- Funciones de notificación personalizables
- Integración de TextUI

## Uso

Los jugadores simplemente necesitan acercarse a un extintor en el mundo del juego y:

1. Aparecerá un mensaje en la pantalla
2. Presionar la tecla de interacción (por defecto: E) para recoger el extintor
3. El extintor se equipará automáticamente

## Requisitos

- Framework ESX o QBCore (dependiendo de la configuración)