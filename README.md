<p>
  <img src="https://github.com/vaibhavjanaskar45/CIVIX-Site-Management-App/raw/main/assets/civixlogo.jpg" alt="Civix Logo" width="200"/>
</p>

# Civix App 🚧

A powerful Flutter-based construction management app built to streamline project oversight, inventory tracking, and team collaboration.

## 🌟 Introduction

**Civix** is a project management solution designed for construction environments with a multi-role hierarchy: **Super Admin**, **Admin**, and **Site Supervisor**. It enables efficient communication, inventory control, and real-time updates on project status.

The app empowers Super Admins to manage all projects, Admins to handle day-to-day project execution, and Supervisors to submit requests and reports from the field.

## 🔑 Key Roles & Permissions

### 👑 Super Admin
- Full control over all features.
- Create/Delete Projects.
- Assign Admins and Supervisors.
- Manage Budgets and Inventory.
- Access to all Reports and Modules.

### 🧑‍💼 Admin (Project Manager)
- Manage assigned projects.
- Receive and approve/reject requests from Supervisors.
- Submit daily progress and budget reports.
- Raise queries to Super Admin.

### 🛠️ Site Supervisor
- Request materials, equipment, or labor.
- View request history (Pending, Approved, Rejected).
- Submit field updates.

## 📌 Core Features

- 🎯 **Create & Manage Projects**  
  Add new construction projects, assign teams, and oversee progress.

- 🗂️ **Modules Dashboard**  
  - Reports - Daily updates from site  
  - Admins - Assign and manage Admin roles  
  - Site Lead - Manage Supervisors  
  - Budget - Set and update project budgets  
  - Add Inventory - Add tools, materials  
  - Assign Inventory - Allocate items to sites  
  - Allocated Inventory - Track assigned items

- 🔔 **Request Handling System**  
  Approve/Reject requests with comment threads for transparency.

- 💬 **Help & Support**  
  Raise internal queries from Admin to Super Admin.

## 🛠️ Tech Stack

- **Flutter** - Cross-platform UI toolkit  
- **Firebase Firestore** - Real-time Database  
- **Dart** - Programming Language

## 🚀 Installation

### Step 1: Clone the Repository
```bash
git clone 
cd civix
```
### Step 2: Install Dependencies
```bash
flutter pub get
```
### Step 3: Run the App
```bash
flutter run
```
### 🔥 Firebase Setup
- Create a Firebase project at Firebase Console.
- Register your app (Android/iOS).
- Download google-services.json (for Android) and place it inside android/app/.
- Enable Firestore and Authentication from Firebase Console.


