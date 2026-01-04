# Dotfiles

## Instalacja na nowym urządzeniu

### 1. Skopiuj klucze SSH (wymaga hasła)
```bash
scp -r yaqub@157.180.41.230:.ssh .ssh
chmod 700 .ssh
chmod 600 .ssh/*
```

### 2. Skopiuj dotfiles
```bash
cd
scp -r yaqub@157.180.41.230:dotfiles dotfiles
dotfiles/install.sh
```

### 3. Skopiuj sekrety
```bash
scp yaqub@157.180.41.230:.secrets .secrets
```

### 4. Zrestartuj terminal

## Po zmianach w dotfiles na VPS

Zaktualizuj na urządzeniu:
```bash
cd
scp -r yaqub@157.180.41.230:dotfiles .
```

Lub przez git (jeśli klucze SSH działają z GitHub):
```bash
cd dotfiles && git pull
```
