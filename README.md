# 🛠️ Genesys Cloud iOS SDK Validator

**A SwiftUI development utility for testing and troubleshooting Genesys Cloud iOS SDK integration**

## 📋 What This Is

A **developer tool** to validate Genesys Cloud iOS SDK setup, test OAuth configurations, diagnose integration issues, and verify API connectivity before building production applications.

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| **✅ SDK Validation** | Tests SDK installation, imports, and configuration |
| **🔐 OAuth Testing** | Validates Client Credentials tokens and permissions |
| **🔍 Error Diagnosis** | Analyzes Error 3, token issues, and configuration problems |
| **📡 API Connectivity** | Tests endpoint access and user data retrieval |
| **🛠️ Build Troubleshooting** | Solves common Xcode/CocoaPods build issues |
| **📋 Step-by-Step Fixes** | Provides actionable solutions for detected issues |

## 🚀 Quick Setup (Copy-Paste Commands)

### 1. Clone & Setup

```bash
# Clone the repository (Note: Update this URL to match your actual repository)
git clone https://github.com/YOUR_ORG/genesys-cloud-ios-sdk-validator.git
cd genesys-cloud-ios-sdk-validator

# Install dependencies
pod install

# Open in Xcode
open GenesysCloudValidator.xcworkspace
```

### 2. First-Time Build Fix (If Needed)

```bash
# If you get "Operation not permitted" errors:
sudo chmod -R 755 ~/Library/Developer/Xcode/DerivedData
pod deintegrate
pod install --repo-update
```

### 3. Get OAuth Token for Testing

```bash
# Replace with your credentials and correct region endpoint

curl -X POST "https://login.mypurecloud.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -u "YOUR_CLIENT_ID:YOUR_CLIENT_SECRET"
```

## 📱 Usage

1. **Launch the app** in Xcode simulator or device
2. **Enter your OAuth credentials** in the configuration screen
3. **Run validation tests** to check SDK integration
4. **Review results** and follow suggested fixes for any issues
5. **Test API connectivity** to ensure proper setup

## 🔧 Common Issues & Solutions

### Build Errors
- **CocoaPods issues**: Run `pod deintegrate && pod install`
- **Xcode cache problems**: Clean build folder (⌘+Shift+K)
- **Permission errors**: Check file permissions in DerivedData

### OAuth Problems
- **Invalid credentials**: Verify Client ID and Secret
- **Wrong environment**: Ensure correct Genesys Cloud region
- **Token expiration**: Refresh tokens as needed

### SDK Integration
- **Import failures**: Check Podfile configuration
- **Missing frameworks**: Verify all dependencies are installed
- **Version conflicts**: Update to compatible SDK versions

## 📚 Documentation

- [Genesys Cloud iOS SDK Documentation](https://mypurecloud.github.io/platform-client-sdk-ios/)
- [Genesys Cloud iOS SDK GitHub Repository](https://github.com/MyPureCloud/platform-client-sdk-ios)
- [OAuth Configuration Guide](https://developer.genesys.cloud/authorization/platform-auth/)
- [Genesys Cloud Developer Center](https://developer.genesys.cloud/)


## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
- Check the [troubleshooting guide](#-common-issues--solutions)
- Review [Genesys Cloud Developer Center](https://developer.genesys.cloud/)
- Visit the [Genesys Cloud Developer Community](https://developer.genesys.cloud/forum/)
- Open an issue in this repository

---

**Note**: This is a development tool for testing SDK integration. Do not use in production applications.
