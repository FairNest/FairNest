# FairNest
Finding roommates is already hard — but living with them? Even harder. From unpaid bills and unwashed dishes to clashing lifestyles and poor communication, living together often turns into a silent war of passive-aggressive post-its and emotional burnout. **FairNest** is built to fix that.

We’re a smart roommate management system designed to make co-living fair, transparent, and harmonious — from the moment you match to how you manage chores, finances, and compatibility. With built-in accountability tools, lifestyle alignment insights, and streamlined task coordination, FairNest transforms shared living from chaotic to collaborative.  
Because a shared space shouldn't come at the cost of your peace.

---

# FairNest – Simple Installation Guide

This guide explains how to install and run FairNest **locally** for testing and demonstration.
No Docker, no external database setup — only the basic run commands.

---

# 1. Requirements

### Backend (Go)

* Go **1.21+**

### Frontend (Flutter)

* Flutter **3.22+**
* Chrome (for Web run)

---

# 2. Clone the Project

```bash
git clone https://github.com/yourusername/FairNest.git
cd FairNest-main
```

Make sure you can see both folders:

```
/server
/fairnestui
```

---

# 3. Run the Backend (Go Server)

Navigate to the backend folder:

```bash
cd server
```

Install dependencies:

```bash
go mod tidy
```

Run the server:

```bash
go run main.go
```

Expected message:

```
Server running on http://localhost:8080
```

> Keep this terminal open.

---

# 4. Run the Frontend (Flutter UI)

Open a new terminal, then navigate to the Flutter folder:

```bash
cd fairnestui
flutter pub get
```

Run the Flutter on Android Devices

This will automatically open the FairNest UI in your browser.

---

# 5. Done

If both steps succeed:

* Backend is running on **[http://localhost:8080](http://localhost:8080)**
* Frontend is running in Chrome

Your installation is complete.

---

## Demo Video
https://www.youtube.com/watch?v=QsN__Zqpbp8

---

## Project Profile
[FairNest — Senior Project Portal (KMUTT)](https://seniorproject.sit.kmutt.ac.th/showproject/CS65-RE75)

---

## Contributors
- Nithit Lertcharoensombat (65130500212) Telphone no : 0888345999, nithit.lert@kmutt.ac.th[@xXNeonKitsuneXx](https://github.com/xXNeonKitsuneXx)
- Panita Chavikkhunram (65130500214) Telphone no : 0972074461, panita.chav@kmutt.ac.th[@nsennes](https://github.com/nsennes)
- Putu Andhika Restu Kurnia (65130500247) Telphone no : 0640964371, putuandhika.rest@kmutt.ac.th[@andhikark](https://github.com/andhikark)
