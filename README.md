# Estolo - Smart Spaza Assistant

Smart Spaza Assistant - MVP for Huawei Hackathon South Africa

## 🎯 Project Overview

Estolo is a Smart Spaza Assistant designed specifically for South African township entrepreneurs. This MVP focuses on three core features to help spaza shop owners run their businesses more efficiently:

1. **POS-lite** - Point of sale system for quick transactions
2. **Supplier Directory** - Easy access to supplier information and contacts
3. **Basic AI Demand Prediction** - Lightweight ML to predict inventory needs

## 🚀 Huawei AppGallery Connect Authentication

The app features advanced authentication powered by Huawei AppGallery Connect with:

- **Email/Password Login** - Traditional authentication method
- **Phone Number + OTP Login** - Perfect for township users who prefer phone-based authentication
- **Social Login** - Support for Huawei ID, Google, Facebook, and Twitter
- **Token-based Sessions** - Secure JWT token management with refresh tokens
- **Offline Session Handling** - Persistent login state
- **User Registration** - Complete account creation flow
- **Password Recovery** - Email-based reset functionality

### Huawei Cloud Benefits:
- **Township-Friendly**: Phone number authentication is simpler than email/password
- **Offline Capability**: SMS OTP works without consistent internet
- **Security**: Enterprise-grade JWT token management
- **Scalability**: Ready for cloud deployment with Huawei infrastructure

## 🏗️ Tech Stack

- **Frontend**: Flutter (mobile-first approach)
- **Backend**: FastAPI with SQLite database
- **Authentication**: Huawei AppGallery Connect - Authentication Service
- **State Management**: Provider pattern
- **Architecture**: MVC with modular structure
- **Storage**: Local storage with SharedPreferences

## 📱 Features

### Core Functionality
- **Product Management**: Add, edit, and track products with barcode scanning
- **Sales Processing**: Quick POS transactions with receipt generation
- **Supplier Directory**: Contact information and ordering capabilities
- **Demand Prediction**: Basic AI to forecast inventory needs based on sales patterns

### Authentication Features
- **Multiple Login Options**: Email, phone, and social providers
- **Secure Sessions**: Token-based authentication with auto-refresh
- **User Profiles**: Personalized dashboard and preferences
- **Registration Flow**: Complete onboarding experience

### Localization
- **South African Focus**: Currency, phone formats, and business practices
- **Mobile-First**: Designed for smartphone usage common in townships
- **Offline-First**: Core functionality available without internet

## 🏁 Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Huawei AppGallery Connect credentials
4. Run the app: `flutter run`

## 🎉 Huawei Hackathon Ready

This MVP is specifically designed for the Huawei Hackathon with:
- Full Huawei AppGallery Connect integration
- Township entrepreneur focus
- Scalable cloud architecture
- Complete authentication system
- Real Huawei API credentials integrated

The app demonstrates how Huawei's cloud services can power solutions for underserved markets in South Africa!
