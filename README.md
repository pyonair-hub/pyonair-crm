# Pyonair CRM

**Your AI Team. Trained on You.**

---

## Overview

Pyonair CRM is a full-featured client relationship management platform with contacts, leads, pipeline management, and email sync. Part of the [Pyonair AI Team](https://pyonair.com) platform for SMBs.

Manage your entire sales pipeline from lead to close with an intuitive interface, powerful automation, and seamless email integration.

### Key Features

- **Contacts & Organizations** -- Centralized contact management with custom attributes
- **Leads & Opportunities** -- Track and nurture leads through customizable stages
- **Pipeline Management** -- Visual Kanban-style deal pipeline with drag-and-drop
- **Email Sync** -- Two-way email integration for seamless communication
- **Activities & Calendar** -- Schedule calls, meetings, and tasks
- **Workflow Automation** -- Automate repetitive sales processes
- **Custom Attributes** -- Extend any entity with custom fields
- **Role-Based Access** -- Granular permissions for teams of any size
- **Dashboard & Reporting** -- Real-time insights into sales performance

---

## Brand

| Element | Value |
|---------|-------|
| Primary Red | `#E63946` |
| Navy | `#0F172A` |
| Font | Inter |

---

## Tech Stack

- **Backend**: Laravel (PHP)
- **Frontend**: Vue.js
- **Database**: MySQL
- **Package Manager**: Composer + npm

---

## Getting Started

### Requirements

- PHP 8.2 or higher
- MySQL 8.0+
- Composer
- Node.js 18+

### Installation

```bash
composer create-project krayin/laravel-crm
```

Or clone this repository and run:

```bash
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
npm install && npm run build
php artisan serve
```

Visit `http://localhost:8000` and log in with the default admin credentials.

---

## License

MIT License -- see [LICENSE](LICENSE) for details.

---

## Credits

Built on [Krayin CRM](https://github.com/krayin/laravel-crm) (MIT License).

Part of the Pyonair AI Team platform -- [pyonair.com](https://pyonair.com)
