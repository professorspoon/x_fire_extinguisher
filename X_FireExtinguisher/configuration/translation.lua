Config.Locale = 'en'

Translation = {
    ['en'] = {
        ['remfire'] = 'Return Extinguisher',
        ['inform1'] = 'Inform',
        ['getfire'] = 'Grabbing Extinguisher',
        ['success2'] = 'Fire extinguisher received!',
        ['helptext'] = 'Take / Replace Extinguisher',
        ['remfire1'] = 'You have returned the fire extinguisher',
        ['success1'] = 'Success',
        ['cooldown'] = 'Cooldown',
        ['cooldown_msg'] = 'You need to wait %s seconds before using an extinguisher again'
    },
    ['de'] = {
        ['remfire'] = 'Feuerlöscher zurückgeben',
        ['inform1'] = 'Information',
        ['getfire'] = 'Feuerlöscher nehmen',
        ['success2'] = 'Feuerlöscher erhalten!',
        ['helptext'] = 'Feuerlöscher nehmen / zurückgeben',
        ['remfire1'] = 'Sie haben den Feuerlöscher zurückgegeben',
        ['success1'] = 'Erfolgreich',
        ['cooldown'] = 'Abklingzeit',
        ['cooldown_msg'] = 'Sie müssen %s Sekunden warten, bevor Sie einen Feuerlöscher wieder benutzen können'
    },
    ['fr'] = {
        ['remfire'] = 'Rendre l\'extincteur',
        ['inform1'] = 'Information',
        ['getfire'] = 'Prendre l\'extincteur',
        ['success2'] = 'Extincteur reçu !',
        ['helptext'] = 'Prendre / Rendre l\'extincteur',
        ['remfire1'] = 'Vous avez rendu l\'extincteur',
        ['success1'] = 'Succès',
        ['cooldown'] = 'Temps de recharge',
        ['cooldown_msg'] = 'Vous devez attendre %s secondes avant de pouvoir utiliser un extincteur'
    },
    ['it'] = {
        ['remfire'] = 'Restituisci estintore',
        ['inform1'] = 'Informazione',
        ['getfire'] = 'Prendi estintore',
        ['success2'] = 'Estintore ricevuto!',
        ['helptext'] = 'Prendi / Restituisci estintore',
        ['remfire1'] = 'Hai restituito l\'estintore',
        ['success1'] = 'Successo',
        ['cooldown'] = 'Tempo di ricarica',
        ['cooldown_msg'] = 'Devi attendere %s secondi prima di poter utilizzare un estintore'
    },
    ['es'] = {
        ['remfire'] = 'Devolver extintor',
        ['inform1'] = 'Información',
        ['getfire'] = 'Tomar extintor',
        ['success2'] = '¡Extintor recibido!',
        ['helptext'] = 'Tomar / Devolver extintor',
        ['remfire1'] = 'Has devuelto el extintor',
        ['success1'] = 'Éxito',
        ['cooldown'] = 'Tiempo de espera',
        ['cooldown_msg'] = 'Debes esperar %s segundos antes de usar un extintor de nuevo'
    }
}

function XTranslate(key)
    local locale = Config.Locale or 'en'
    
    if Translation[locale] and Translation[locale][key] then
        return Translation[locale][key]
    else
        return 'Missing Translation: ' .. key
    end
end 