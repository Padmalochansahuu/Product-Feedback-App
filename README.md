# 📝 Product Feedback App – Built with Flutter & Firebase

## 📱 Overview

The **Product Feedback App** is a modern, mobile-first solution designed to collect user feedback and provide insightful analytics for administrators.  
Developed using **Flutter**, **Firebase**, and **GetX**, it supports role-based access for both **Users** and **Admins** with a clean, responsive, and animated interface.

---

## 🚀 Key Highlights

- 🔐 **Role-Based Registration & Login**  
  Users can choose to register as **Admin** or **User** during sign-up. The app handles navigation and access dynamically based on the selected role.

- 🔄 **Persistent Login & Session Handling**  
  Seamless experience maintained even after app restart using Firebase Auth session management.

- 🎨 **Fully Animated & Modern UI**  
  Includes gradient themes, glass morphism cards, hover effects, smooth transitions, and responsive layouts powered by `flutter_animate`.

- 📊 **Admin Analytics Dashboard**  
  Real-time data visualization for total reviews, average rating, rating distribution, and top contributors.

---

## ✨ Features by Role

### 🧑‍💻 User Panel

- Register and log in with email/password
- Select role during registration
- Welcome card with user info and online status
- Submit feedback with:
  - Star rating (1–5 stars)
  - Multi-line comment with validation
  - Optional image upload (with preview)
- View previous feedback submissions
- Responsive UI with clean transitions

---

### 👩‍💼 Admin Panel

- Admin dashboard with:
  - Total number of reviews
  - Average rating
  - Percentage of 4⭐ and 5⭐ ratings
- Top Contributors widget
- Rating Distribution chart
- Expandable feedback cards with comment and image preview
- Search bar for keyword/date filtering
- Fully responsive layout with modern visuals

---

## 🧱 Tech Stack

- **Framework:** Flutter 
- **Backend:** Firebase Auth & Firestore
- **State Management:** GetX
- **Animations:** flutter_animate
- **Styling:** Custom theme with gradients, Google Fonts (Inter), and Material 3
- **Image Upload:** image_picker



