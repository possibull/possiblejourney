# PossibleJourney Project Guidelines

This document serves as a comprehensive reference for all project processes, conventions, and user preferences. It should be consulted whenever starting work on this project to ensure consistency and proper workflow.

## Version Management

### Starting a New Version

**Script**: `./start-new-version.sh <type>`

**Usage**: The script requires one argument specifying the version type:
- `major`: Increments major version (1.9 → 2.0)
- `minor`: Increments minor version (1.9 → 1.10)  
- `build`: Increments build number (build 1 → build 2)

**Process**:
1. The script reads the current version from `main` branch's `latest-version.json`
2. Creates a new branch with naming convention: `v{version}-build{build}`
3. Updates version in `PossibleJourney.xcodeproj/project.pbxproj`
4. Updates `latest-version.json` on the development branch
5. Commits the version changes

**Important Conventions**:
- Always use the latest version from the `main` branch's `latest-version.json` as the source of truth
- Do NOT update the main branch's `latest-version.json` until deployment
- Update `latest-version.json` on the development branch during development
- Copy the updated `latest-version.json` to main branch only on deployment

### Deployment Process

**When pushing to GitHub**:
- Push the main branch with ONLY the updated `latest-version.json` and nothing else
- Use the deploy script for proper deployment workflow

## Release Notes Guidelines

### Content Restrictions
- **DO NOT** mention hidden themes or Easter eggs in release notes
- Keep release notes focused on user-facing features and improvements
- Be professional and clear about what users can expect

### Release Notes Management
- Update release notes in `latest-version.json` during development
- Use the `combine-release-notes.sh` script to merge release notes when needed

## Project Structure

### Key Directories
- `PossibleJourney/` - Main iOS app source code
- `scripts/` - Build and deployment scripts
- `fastlane/` - Automated deployment configuration
- `builds/` - Build artifacts and archives

### Important Files
- `latest-version.json` - Version tracking and release notes
- `start-new-version.sh` - Version creation script
- `deploy.sh` - Deployment script
- `exportOptions.plist` - App Store export configuration

## Development Workflow

### TDD (Test-Driven Development) with Slice Down Methodology
- **Always write tests first** before implementing features
- **Slice down approach**: Break complex features into small, testable slices
- **Red-Green-Refactor cycle**:
  1. Write failing test (Red)
  2. Implement minimal code to pass test (Green)
  3. Refactor while keeping tests passing
- **Test coverage**: Aim for comprehensive test coverage of all new functionality
- **Integration tests**: Test complete user workflows, not just individual components

### Branch Management
- Development branches follow pattern: `v{version}-build{build}`
- Main branch should only contain stable, deployable code
- Version information flows from main → development → main (on deployment)

### Testing
- **Run tests before committing changes**
- **Write tests for all new features and bug fixes**
- Use `show-build-errors.sh` to check for build issues
- **Always use iPhone 16 simulator for testing**: `-destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5'`
- **Run one test at a time during development** to isolate issues and reduce debugging complexity
- Test on both simulator and device when possible
- **Ensure all tests pass before merging**

## Build and Archive Management

### Scripts Available
- `build-with-tmp.sh` - Build with temporary configuration
- `manage_archives.sh` - Archive management
- `move_to_organizer.sh` - Move builds to Xcode Organizer
- `archive_check.sh` - Archive validation

### Build Artifacts
- `.ipa` files for distribution
- `.dSYM` files for crash symbolication
- App icons in `AppIconSet/` directory

### App Store Connect Authentication
- **App-Specific Password Required**: For deploying to TestFlight/App Store, you need an app-specific password
- **Find Existing Password in Shell History**:
  ```bash
  history | grep -i "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD\|app-specific" | tail -10
  ```
- **Generate New App-Specific Password** (if needed):
  1. Go to [appleid.apple.com](https://appleid.apple.com)
  2. Sign in with your Apple ID (ted@mrpossible.com)
  3. Navigate to "Sign-in and Security" → "App-Specific Passwords"
  4. Click "Generate Password" for "PossibleJourney"
  5. Copy the generated password (it will only be shown once)
- **Set Environment Variable**: 
  ```bash
  export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="your-app-specific-password"
  ```
- **For GitHub Actions**: Add the password as a repository secret named `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
- **Alternative**: Use App Store Connect API Key (recommended for production)
- **Note**: Regular Apple ID password will not work for automated deployments
- **Current Known Passwords** (from shell history):
  - `thkd-bbia-iyyh-guxx` (most recent)
  - `hzkk-zjif-yber-yxlk` (previous)

## Development Process

### Feature Development with TDD
1. **Plan the feature** and break it down into small, testable slices
2. **Write tests first** for the smallest slice
3. **Implement minimal code** to make tests pass
4. **Refactor** while keeping tests green
5. **Repeat** for each slice until feature is complete
6. **Integration testing** to ensure all slices work together

### Bug Fix Process
1. **Write a failing test** that reproduces the bug
2. **Implement the fix** to make the test pass
3. **Ensure no regressions** by running all tests
4. **Refactor if needed** while maintaining test coverage

## User Preferences and Conventions

### Communication Style
- Be direct and efficient in responses
- Focus on actionable solutions
- Provide clear next steps when completing tasks

### Code Quality
- Follow Swift best practices
- Maintain consistent naming conventions
- Include appropriate comments for complex logic
- **Write testable code** that supports TDD methodology

### File Management
- Use relative paths when possible
- Keep build artifacts organized
- Maintain backup copies of important configurations

## Troubleshooting

### Common Issues
1. **Version conflicts**: Always check main branch's `latest-version.json`
2. **Build errors**: Use `show-build-errors.sh` for diagnostics
3. **Archive issues**: Check `manage_archives.sh` for archive management
4. **Authentication failures**: Use shell history to find existing app-specific passwords

### Authentication Troubleshooting
- **If deployment fails with authentication error**: Search shell history for existing passwords
- **Shell History Search Commands**:
  ```bash
  # Search for app-specific password usage
  history | grep -i "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD\|app-specific" | tail -10
  
  # Search for any password-related commands
  history | grep -i "password\|FASTLANE_PASSWORD" | tail -15
  
  # Search for specific password patterns
  history | grep -E "hzkk-|thkd-" | tail -5
  ```
- **Known Working Passwords** (from shell history):
  - `thkd-bbia-iyyh-guxx` (most recent, verified working)
  - `hzkk-zjif-yber-yxlk` (previous, may need regeneration)
- **Quick Fix**: Copy password from history and set environment variable:
  ```bash
  export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="thkd-bbia-iyyh-guxx"
  ```

### Getting Help
- Check this document first for process questions
- Review script comments for usage instructions
- Consult `DEPLOYMENT.md` for deployment-specific guidance

### Shell History Best Practices
- **Search Before Regenerating**: Always search shell history for existing app-specific passwords
- **Password Patterns**: App-specific passwords follow pattern: `xxxx-xxxx-xxxx-xxxx`
- **History Commands**:
  ```bash
  # Most comprehensive search
  history | grep -i "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" | tail -10
  
  # Search for specific password patterns
  history | grep -E "[a-z]{4}-[a-z]{4}-[a-z]{4}-[a-z]{4}" | tail -5
  
  # Search for export commands with passwords
  history | grep "export.*FASTLANE.*PASSWORD" | tail -5
  ```
- **Security Note**: Shell history may contain sensitive passwords - be cautious when sharing terminal sessions
- **Password Rotation**: If passwords stop working, generate new ones at appleid.apple.com

## Quick Reference Commands

```bash
# Start new version
./start-new-version.sh major|minor|build

# Deploy
./deploy.sh

# Check build errors
./show-build-errors.sh

# Manage archives
./manage_archives.sh

# Build with temp config (auto-commits on success)
./build-with-tmp.sh

# Deploy to TestFlight (requires app-specific password)
./scripts/deploy.sh beta

# Deploy to App Store (requires app-specific password)
./scripts/deploy.sh release

# Find app-specific password in shell history
history | grep -i "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD\|app-specific" | tail -10
```

## Build Workflow

### Using build-with-tmp.sh (Recommended)
- **Always use `./build-with-tmp.sh` for builds during development**
- **Auto-commits changes after successful build**
- **Creates detailed build logs in temporary directory**
- **Provides comprehensive error analysis**
- **Only commit manually if build fails and you need to fix issues**

### Manual Build Process (Not Recommended)
- Only use direct `xcodebuild` commands for testing specific configurations
- **Must manually commit changes after successful builds**
- **No automatic logging or error analysis**
- **Risk of forgetting to commit changes**

---

**Last Updated**: This document should be updated whenever new processes or conventions are established.

**Note**: This document serves as the primary reference for project workflows. Always consult this before starting work to ensure proper adherence to established conventions. 