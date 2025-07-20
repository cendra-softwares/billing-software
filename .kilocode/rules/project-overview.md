# 🍽️ Cendra – Smart Restaurant Management System

Cendra is a modern, offline-first, multi-restaurant management system built with **Flutter**, **Riverpod**, **Isar**, and **Supabase**. It enables restaurant owners and staff to efficiently manage tables, orders, staff, receipts, and smart table predictions.

---

## 🚀 Core Features

- 🔐 **Auth System**

  - Email/Password or OTP-based login via Supabase Auth
  - Role-based access (Owner, Admin, Waiter, Kitchen Staff)

- 🏢 **Multi-Restaurant Support**

  - Each account can create or join a restaurant
  - Supports cloud sync and offline-first functionality

- 🪑 **Smart Table Management**

  - Real-time table availability tracking
  - Table timer to calculate average wait/occupancy time

- 🧾 **Order & Receipt Management**

  - Offline-first order entry
  - Receipt history and real-time updates

- 🧠 **Smart Predictions**

  - Table occupancy predictions based on menu item duration
  - Real-time adjustments based on live data

- 🛼 **Offline Mode with Isar**

  - All features work offline
  - Syncs with Supabase when online

---

## 🧰 Tech Stack

| Layer      | Technology                                 |
| ---------- | ------------------------------------------ |
| Frontend   | Flutter                                    |
| State Mgmt | Riverpod                                   |
| Local DB   | Isar DB                                    |
| Backend    | Supabase (Auth, DB, Storage)               |
| Hosting    | Vercel (for web), Play Store (for Android) |

---

## 🧹 Modules

1. **Authentication**

   - Sign up / login
   - Password or OTP auth (via Supabase)

2. **Restaurant Setup**

   - Create / Join restaurant
   - Upload logo, define table layout, config

3. **Employee Management**

   - Create staff accounts
   - Assign roles and permissions

4. **Table System**

   - Track availability, assign orders
   - Auto-track table timers

5. **Menu & Orders**

   - Add/manage menu items
   - Take & manage orders

6. **Receipts & Billing**

   - Track order history
   - Generate & export receipts

7. **Sync System**

   - Isar local → Supabase cloud
   - Conflict resolution and offline caching

---

## 🛠️ Project Structure (Planned)

```
lib/
│
├── main.dart
├── core/                # Core helpers, constants
├── auth/                # Login, signup, auth state
├── models/              # Isar + Supabase model definitions
├── features/            # Individual feature modules
│   ├── restaurant/      # Create, update, sync restaurant
│   ├── tables/
│   ├── orders/
│   ├── receipts/
│   └── config/
├── services/            # Supabase, sync, storage
└── ui/                  # Widgets, themes, responsive layouts
```

---

## 📅 Development Roadmap

### Phase 1: Auth & Restaurant Setup

- [ ] Login / Signup with Supabase
- [ ] Create / Join restaurant
- [ ] Store config locally (Isar) + Supabase

### Phase 2: Core Features

- [ ] Add table layout builder
- [ ] Staff creation and login
- [ ] Order creation and tracking
- [ ] Receipt generation

### Phase 3: Smart Features

- [ ] Table occupancy prediction engine
- [ ] Analytics dashboard

---

## 📡 Sync Logic

- Isar as primary local DB
- Supabase is cloud backend
- Manual or auto sync on connectivity

---

## 👤 Contributors

- **Hhs Shh** — Dev + Architect
- **ChatGPT** — AI Pair Programmer

---

## 📘 License

MIT License

---
