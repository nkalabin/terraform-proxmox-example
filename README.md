# Terraform модуль для Proxmox VE

Этот проект содержит Terraform конфигурацию для автоматизированного создания виртуальных машин в Proxmox VE из готовых шаблонов. Модуль поддерживает настройку cloud-init, сетевых параметров и ресурсов VM через переменные.

## Что делает этот модуль

- 🖥️ Создает виртуальные машины из шаблонов Proxmox
- ⚙️ Автоматически настраивает cloud-init для создания пользователей
- 🌐 Конфигурирует сетевые параметры и IP адресацию
- 🔧 Позволяет настраивать ресурсы VM (CPU, память, диск)
- 🏷️ Добавляет теги и метки для управления VM

## 🚀 Быстрый старт

### 1. Настройка проекта

Скопируйте пример конфигурации и отредактируйте под свою среду:
```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # или любой другой редактор
```

### 2. Необходимые изменения в `terraform.tfvars`

В файле `terraform.tfvars` обязательно измените:

**Подключение к Proxmox:**
- `proxmox_api_url` - URL вашего Proxmox сервера (например: `https://192.168.1.100:8006/api2/json`)
- `proxmox_api_token_id` - ID токена API (например: `root@pam!terraform`)
- `proxmox_api_token_secret` - Секретный ключ токена

**Параметры VM:**
- `target_node` - имя узла Proxmox где создается VM
- `template_name` - имя шаблона для клонирования
- `vm_name` - имя создаваемой виртуальной машины
- `vm_user` и `vm_password` - данные пользователя для cloud-init

### 3. Запуск

```bash
# Инициализация Terraform
terraform init

# Просмотр плана создания
terraform plan

# Создание виртуальной машины
terraform apply
```

## ⚙️ Подробная настройка

### Создание API токена в Proxmox

Для работы с Proxmox через Terraform нужен API токен:

1. Войдите в веб-интерфейс Proxmox
2. Перейдите в **Datacenter** → **Permissions** → **API Tokens**
3. Нажмите **Add** → **API Token**
4. Заполните:
   - **User ID**: `root@pam!terraform` (или другой пользователь)
   - **Token ID**: любое имя (например: `terraform`)
   - **Expire**: оставьте пустым для бессрочного токена
5. Скопируйте полученный **Token ID** и **Secret**

### Подготовка шаблона VM

Перед использованием шаблон должен быть подготовлен для cloud-init. Выполните следующие команды в вашем шаблоне:
```bash
# --- Cloud-init настройка ---
rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg || true
rm -f /etc/cloud/cloud-init.disabled || true
mkdir -p /etc/cloud/cloud.cfg.d
printf "%s\n" "datasource_list: [ NoCloud, ConfigDrive, OVF, MAAS, VMware, OpenStack, CloudStack, Ec2, Azure, GCE, Oracle, Aliyun ]" > /etc/cloud/cloud.cfg.d/99_enable_all_datasources.cfg

# --- Настройка GRUB ---
if [ -f /etc/default/grub ]; then
  sed -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.*#GRUB_CMDLINE_LINUX_DEFAULT=\"console=tty0 console=ttyS0,115200 earlycon=ttyS0,115200 loglevel=7\"#" /etc/default/grub || true
  sed -i "s#^GRUB_CMDLINE_LINUX=.*#GRUB_CMDLINE_LINUX=\"\"#" /etc/default/grub || true
  command -v update-grub >/dev/null 2>&1 && update-grub || true
fi

# --- Очистка apt ---
apt-get -y autoremove || true
apt-get clean || true

# --- machine-id ---
if [ -f /etc/machine-id ]; then truncate -s 0 /etc/machine-id || true; fi
rm -f /var/lib/dbus/machine-id || true
ln -sf /etc/machine-id /var/lib/dbus/machine-id || true

# --- Очистка SSH host keys ---
rm -f /etc/ssh/ssh_host_* || true

# --- Зануление свободного места ---
set +e
dd if=/dev/zero of=/EMPTY bs=1M count=1024 >/dev/null 2>&1 || true
rm -f /EMPTY
set -e
sync
echo "✅ Cloud-init, GRUB и очистка завершены."
```

## 🔒 Безопасность

**⚠️ ВАЖНО**: Файл `terraform.tfvars` содержит секретные данные и НЕ должен попадать в репозиторий!

- ✅ Файл `terraform.tfvars` уже добавлен в `.gitignore`
- ✅ Используйте `terraform.tfvars.example` как шаблон
- 🔑 Храните токены API и пароли в безопасном месте
- 🌐 Для продакшена установите `proxmox_tls_insecure = false`

## 📁 Структура проекта

```
proxmox-terraform/
├── main.tf                    # Основная конфигурация VM
├── variables.tf               # Определения переменных
├── outputs.tf                 # Выводы после создания
├── versions.tf                # Версии провайдеров
├── terraform.tfvars          # Ваши настройки (НЕ коммитить!)
├── terraform.tfvars.example  # Пример настроек для начала работы
├── .gitignore                # Исключения для Git (уже настроен)
└── README.md                 # Документация проекта
```

## ✨ Особенности

- ✅ Полное клонирование шаблонов VM (`full_clone = true`)
- ✅ Автоматическая настройка cloud-init для пользователей
- ✅ Поддержка SSH ключей для безопасного доступа
- ✅ Настраиваемые ресурсы (CPU ядра, память, размер диска)
- ✅ Гибкая сетевая конфигурация (VLAN, мосты)
- ✅ Теги и метки для организации VM
- ✅ Валидация входных параметров

## Устранение неполадок

### Ошибка "no bootable device"

Если VM не загружается, проверьте:

1. **Тип диска в шаблоне:**
   ```bash
   qm config <template_id>
   ```

2. **Измените параметр `boot` в `main.tf`:**
   - Если `bootdisk: scsi0` → `boot = "order=scsi0"`
   - Если `bootdisk: virtio0` → `boot = "order=virtio0"`
   - Если `bootdisk: ide0` → `boot = "order=ide0"`

### Подключение к VM

После создания VM подключитесь через SSH:
```bash
ssh <vm_user>@<vm_ip_address>
```

## Удаление

Для удаления созданных ресурсов:
```bash
terraform destroy
```

## Лицензия

MIT