# X_FireExtinguisher

Una risorsa FiveM che consente ai giocatori di raccogliere e utilizzare gli estintori presenti in tutto il mondo di gioco.

## Caratteristiche

- Raccogli qualsiasi estintore trovato nel mondo di gioco
- Prestazioni ottimizzate con un uso minimo delle risorse
- Supporto per i framework ESX e QBCore
- Selezione automatica dell'estintore dopo averlo raccolto
- Sistema di raffreddamento per prevenire abusi
- Notifiche e TextUI personalizzabili
- Supporto multilingua

## Installazione

1. Scarica la risorsa
2. Posizionala nella cartella resources del tuo server
3. Aggiungi `ensure X_FireExtinguisher` al tuo server.cfg
4. Configura le impostazioni in `configuration/config.lua` secondo le tue preferenze

## Configurazione

Lo script è altamente configurabile tramite il file `configuration/config.lua`:

- Selezione del framework (ESX o QBCore)
- Versione ESX (nuova o vecchia)
- Impostazioni del tempo di raffreddamento
- Funzioni di notifica personalizzabili
- Integrazione TextUI

## Utilizzo

I giocatori devono semplicemente avvicinarsi a un estintore nel mondo di gioco e:

1. Apparirà un suggerimento sullo schermo
2. Premere il tasto di interazione (predefinito: E) per raccogliere l'estintore
3. L'estintore sarà automaticamente equipaggiato

## Requisiti

- Framework ESX o QBCore (a seconda della configurazione)