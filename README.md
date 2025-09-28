# PossibleJourney

A Kaizen-based personal development app that transforms daily habits into measurable progress through intelligent task management and continuous improvement principles.

## 🎯 Vision: From 75 Hard to Kaizen

PossibleJourney is evolving from a rigid 75 Hard discipline model to a sophisticated **Kaizen (continuous improvement)** system that adapts to your growth journey. Unlike traditional habit trackers that focus on streaks and all-or-nothing approaches, our Kaizen model recognizes that sustainable progress comes through intelligent task management and measured improvement.

## 🌱 The Kaizen Task System

### Three Task Types for Sustainable Growth

#### 1. **Growth Tasks** 🌱
**Purpose**: Drive measurable progress and skill development
- **Requires**: Progress Rule + Metric Link
- **Examples**: 
  - Workout: "Lift ≥ last session" (delta_threshold)
  - Taxes: "Complete ≥ 1 tax section" (count_min)
  - Networking: "≥ 5 connections in 7 days" (rolling_window)
- **Key Feature**: Check-off only works if the progress rule passes

#### 2. **Maintenance Tasks** ⚙️
**Purpose**: Maintain essential daily habits without pressure
- **Type**: Simple daily check
- **Examples**: Hydration, flossing, daily walk
- **Key Feature**: Missing doesn't restart your program

#### 3. **Recovery Tasks** 🛌
**Purpose**: Structured rest and self-care
- **Type**: Restorative activities
- **Examples**: Sleep hygiene, meditation, relaxation
- **Key Feature**: Missing = warning, not restart (encourages rest without penalty)

### Progress Rules Engine

The heart of our Kaizen system is the **Progress Rules Engine** that ensures genuine improvement:

- **`delta_threshold`**: "Lift ≥ last session" - Must improve from previous performance
- **`count_min`**: "Complete ≥ 1 tax section" - Minimum quantity requirements
- **`boolean_condition`**: "No phone in bedroom" - Yes/no validation
- **`rolling_window`**: "≥ 5 connections in 7 days" - Time-based accumulation

**Core Principle**: You can't just check a box - you must actually meet the progress criteria to complete a Growth Task.

### 4. Missed Task Protocol (Instead of Restart)

When a Growth Task fails, we don't restart your program. Instead, we trigger intelligent reflection and adaptation:

**Reflection Questions**:
- "Why did you miss? Too big? Wrong time? Environment?"

**Kaizen Tweaks**:
- **Shrink**: Reduce scope/difficulty
- **Reschedule**: Change timing
- **Swap**: Replace with more suitable task

**Learning Log**: All adaptations are tracked in your program history, creating a personalized learning system that gets smarter over time.

### 5. Review Windows

At Day 7, Day 14, or user-defined intervals, PossibleJourney shows:

**Metric Trends**: Track progress across pillars (Health/Wealth/Relationships)

**Checkbox Loop Detection**: Flag tasks that pass completion but show no metric growth - indicating "going through the motions" without real progress

**Failure Pattern Analysis**: Identify tasks that failed ≥ 2 times and suggest specific tweaks

**Sprint Maintenance**: Keep your growth plan alive even when individual days go sideways

### 6. Program Modes

Choose your approach when creating a new program:

#### **Strict Mode (Classic)**
- **Philosophy**: Traditional 75 Hard discipline
- **Behavior**: Miss 1 task → restart program
- **Target**: Legacy users who prefer the original approach
- **Maintains**: Existing user expectations and habits

#### **Kaizen Mode (Default)**
- **Philosophy**: Continuous improvement with learning
- **Behavior**: Missed Task Protocol + Review Windows
- **Features**: Reflection, adaptation, periodic optimization
- **Target**: Users ready for sustainable growth

**User Choice**: Clear mode selection at program creation, with Kaizen Mode as the default for new users.

## 🚀 Key Features

- **Intelligent Progress Tracking**: Real improvement, not just completion
- **Adaptive Task Management**: Different rules for different types of growth
- **Sustainable Approach**: No harsh restarts, encouraging continuous improvement
- **Comprehensive Analytics**: Track real progress over time
- **Flexible Templates**: Create custom programs for any goal

## 📱 Current Status

**Version 2.0** - Major Kaizen Transformation
- Complete redesign from 75 Hard to Kaizen model
- New task typing system with progress rules
- Enhanced analytics and progress tracking
- Sustainable habit formation approach

## 🛠️ Development

### Quick Start
```bash
# Build the project
./build-with-tmp.sh

# Start new version
./start-new-version.sh major|minor|build

# Deploy to TestFlight
./scripts/deploy.sh beta
```

### Documentation
- **[Project Guidelines](PROJECT_GUIDELINES.md)** - Development processes, conventions, and workflows
- **[Build System](BUILD_SYSTEM_README.md)** - Build automation and error handling
- **[Auto-Commit System](AUTO_COMMIT_README.md)** - Automated version control
- **[Scripts Documentation](scripts/README.md)** - Version management and deployment
- **[Fastlane Setup](fastlane/README.md)** - App Store deployment automation

### Development Philosophy
- **Test-Driven Development (TDD)** with slice-down methodology
- **Continuous Integration** with automated builds and testing
- **Version-First Development** with proper branching and release management
- **User-Centered Design** focused on sustainable habit formation

## 🎨 Themes & Personalization

PossibleJourney includes a rich theming system with:
- **Default Themes**: Clean, professional designs
- **Special Themes**: Birthday celebrations with animated balloons
- **Hidden Themes**: Discoverable through app exploration
- **Theme-Aware UI**: Consistent design language across all components

## 📊 Analytics & Progress

Track your Kaizen journey with:
- **Progress Metrics**: Real improvement over time
- **Task Performance**: Success rates by task type
- **Growth Patterns**: Identify what drives your progress
- **Recovery Insights**: Balance between growth and rest

## 🔄 Migration from 75 Hard

The app maintains backward compatibility while introducing the new Kaizen system:
- Existing programs continue to work
- New programs use the Kaizen task system
- Gradual migration path for existing users
- Enhanced features for all users

## 📈 Roadmap

### Version 2.0 (Current)
- ✅ Kaizen task system implementation
- ✅ Progress rules engine
- ✅ Three task types (Growth, Maintenance, Recovery)
- ✅ Enhanced analytics

### Future Versions
- Advanced progress rule customization
- AI-powered task suggestions
- Social features and community challenges
- Integration with health and fitness apps

## 🤝 Contributing

This project follows strict development guidelines:
1. **Read [Project Guidelines](PROJECT_GUIDELINES.md)** before contributing
2. **Follow TDD methodology** - write tests first
3. **Use proper version management** - create branches for features
4. **Maintain code quality** - comprehensive testing and documentation

## 📄 License

Private project - All rights reserved.

---

**PossibleJourney** - Where discipline meets intelligence, and habits become growth.

*"The journey of a thousand miles begins with a single step, but the journey of continuous improvement begins with understanding what that step actually means."*
