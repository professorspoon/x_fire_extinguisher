# X_FireExtinguisher

Eine FiveM-Ressource, die es Spielern ermöglicht, Feuerlöscher in der gesamten Spielwelt aufzuheben und zu benutzen.

## Funktionen

- Hebe jeden Feuerlöscher auf, den du in der Spielwelt findest
- Optimierte Leistung mit minimalem Ressourcenverbrauch
- Unterstützung für ESX- und QBCore-Frameworks
- Automatische Waffenauswahl nach dem Aufheben des Feuerlöschers
- Abkühlsystem zur Verhinderung von Missbrauch
- Anpassbare Benachrichtigungen und TextUI
- Mehrsprachige Unterstützung

## Installation

1. Lade die Ressource herunter
2. Platziere sie im Resources-Ordner deines Servers
3. Füge `ensure X_FireExtinguisher` zu deiner server.cfg hinzu
4. Konfiguriere die Einstellungen in `configuration/config.lua` nach deinen Wünschen

## Konfiguration

Das Skript ist über die Datei `configuration/config.lua` hochgradig konfigurierbar:

- Framework-Auswahl (ESX oder QBCore)
- ESX-Version (neu oder alt)
- Abkühlzeit-Einstellungen
- Anpassbare Benachrichtigungsfunktionen
- TextUI-Integration

## Nutzung

Spieler müssen sich lediglich einem Feuerlöscher in der Spielwelt nähern und:

1. Eine Aufforderung erscheint auf dem Bildschirm
2. Drücke die Interaktionstaste (Standard: E), um den Feuerlöscher aufzuheben
3. Der Feuerlöscher wird automatisch ausgerüstet

## Anforderungen

- ESX- oder QBCore-Framework (je nach Konfiguration)