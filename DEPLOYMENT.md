# Automated Deployment to App Store Connect

This project is set up with automated deployment to App Store Connect using Fastlane and GitHub Actions.

## 🚀 Quick Start

### Option 1: Local Deployment (Recommended for testing)

```bash
# Deploy to TestFlight
./scripts/deploy.sh beta

# Deploy to App Store (requires confirmation)
./scripts/deploy.sh release

# Full release process (increment build + deploy)
./scripts/deploy.sh full
```

### Option 2: GitHub Actions (Fully automated)

Push to the `main` branch to automatically deploy to TestFlight, or use the GitHub Actions UI to manually trigger deployments.

## 📋 Prerequisites

### 1. Apple Developer Account Setup

You need to set up the following in your Apple Developer account:

- **App Store Connect API Key** (recommended) or **App-Specific Password**
- **Distribution Certificate** (p12 file)
- **Provisioning Profile** for App Store distribution

### 2. GitHub Secrets Setup

For GitHub Actions, add these secrets to your repository:

```
P12_BASE64              # Base64 encoded p12 certificate
P12_PASSWORD            # Password for the p12 certificate
APPSTORE_ISSUER_ID      # App Store Connect API Issuer ID
APPSTORE_KEY_ID         # App Store Connect API Key ID
APPSTORE_PRIVATE_KEY    # App Store Connect API Private Key
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD  # App-specific password
```

### 3. Local Environment Setup

For local deployment, you need to:

1. **Install Fastlane**: `brew install fastlane`
2. **Set up App Store Connect API Key** or use app-specific password
3. **Install certificates and provisioning profiles** in Xcode

## 🔧 Configuration

### Fastlane Configuration

- **Fastfile**: `fastlane/Fastfile` - Contains deployment lanes
- **Appfile**: `fastlane/Appfile` - Contains app configuration

### Available Lanes

- `fastlane build` - Build the app locally
- `fastlane beta` - Build and upload to TestFlight
- `fastlane release` - Build and upload to App Store
- `fastlane deploy` - Increment build number and deploy to TestFlight
- `fastlane full_release` - Increment build number and deploy to App Store

## 🎯 Deployment Workflow

### TestFlight Deployment (Beta)

1. **Automatic**: Push to `main` branch triggers TestFlight deployment
2. **Manual**: Run `./scripts/deploy.sh beta` locally
3. **GitHub Actions**: Use the "Deploy to App Store Connect" workflow

### App Store Deployment (Release)

1. **Manual**: Run `./scripts/deploy.sh release` locally
2. **GitHub Actions**: Use the workflow dispatch with `release` option

## 🔐 Security

- **Never commit** certificates, passwords, or API keys
- Use GitHub Secrets for sensitive data
- Use App Store Connect API Keys instead of passwords when possible
- Store certificates securely and use environment variables

## 📱 Build Process

The automated deployment:

1. **Increments build number** (if using deploy lanes)
2. **Builds the app** using Xcode
3. **Creates IPA file** with proper signing
4. **Uploads to App Store Connect**
5. **Processes for TestFlight/App Store**

## 🚨 Troubleshooting

### Common Issues

1. **Certificate Issues**: Ensure certificates are valid and properly installed
2. **Provisioning Profile**: Make sure the profile matches your bundle ID
3. **API Key Permissions**: Ensure your App Store Connect API key has the right permissions
4. **Build Failures**: Check Xcode build logs for compilation errors

### Debug Commands

```bash
# Test Fastlane setup
fastlane lanes

# Run with verbose output
fastlane beta --verbose

# Check certificates
fastlane run cert

# Check provisioning profiles
fastlane run sigh
```

## 📈 Monitoring

- **TestFlight**: Check App Store Connect for build processing status
- **App Store**: Monitor review process in App Store Connect
- **GitHub Actions**: Check Actions tab for deployment status

## 🔄 Continuous Integration

The GitHub Actions workflow automatically:

- Builds on every push to `main`
- Deploys to TestFlight for testing
- Provides manual deployment options
- Handles code signing and provisioning

## 📞 Support

For deployment issues:

1. Check the troubleshooting section above
2. Review Fastlane documentation: https://docs.fastlane.tools
3. Check GitHub Actions logs for detailed error messages
4. Verify Apple Developer account settings 