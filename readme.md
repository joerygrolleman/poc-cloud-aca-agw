Om een deployment te starten van de bicep, voer het volgende uit vanuit de root van het project:

### Hub

```ps1
    az deployment group create --template-file .\bicep\hub\main.bicep --resource-group rg-poc-agw-aca-hub
```

### Spokes
