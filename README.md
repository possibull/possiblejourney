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

#### 🔑 How Progress Rules Work

**1. Every Growth Task has a Linked Metric**
You can't create a Growth Task without tying it to a measurable metric (weight lifted, hours slept, tax sections completed, meaningful connections, etc.).
- Example: Strength Training → metric = bench_press_reps × weight

**2. User Chooses the Rule Type**
When creating/editing a task, you assign a rule type that tells PJ how to evaluate progress.

**Rule Types**:
- **`delta_threshold`**: Today's value ≥ last value + minimum improvement
  - Example: Bench press must add +1 rep or +2.5 lbs vs last session
- **`count_min`**: Must complete a minimum count
  - Example: Finish ≥1 tax section today
- **`boolean_condition`**: Must meet a true/false requirement
  - Example: Sleep ≥7 hrs AND phone_in_room == false
- **`rolling_window`**: Must hit a target within a moving timeframe
  - Example: ≥5 meaningful connections in the past 7 days

**3. Check-off Logic**
When you try to check off a Growth Task:
- PJ checks if you logged the metric for today
- PJ evaluates the Progress Rule using today's input + history
- If rule passes → ✅ task complete
- If rule fails → ❌ task blocked → Missed Task Protocol triggers

**Key Innovation**: You can't just tap "done." You must prove progress by meeting the rule.

**4. Example Walkthrough**
- Task: Strength Training
- Metric: Bench Press Weight/Reps
- Progress Rule: delta_threshold (+1 rep or +2.5 lbs)
- History: Last session = 135 lbs × 8 reps
- Today: You log 135 lbs × 9 reps
- PJ checks → 9 reps vs 8 reps → meets delta_threshold → ✅ task passes
- If you logged 135 × 8 again, PJ blocks check-off and asks: "Why no progress? Do you want to reduce scope or change the task?"

**Core Principle**: You can't just check a box - you must actually meet the progress criteria to complete a Growth Task.

#### 📝 Where to Edit Progress Rules in PJ

Progress Rules are designed to be flexible and adaptive, with multiple editing locations throughout your journey:

**1. At Task Creation**
When creating a Growth Task, PJ requires you to set:
- **Linked Metric**: e.g., "Bench Press Weight/Reps", "Sleep Hours", "Tax Sections"
- **Rule Type**: Choose from delta_threshold, count_min, boolean_condition, rolling_window
- **Config Details**: e.g., "+1 rep or +2.5 lbs," "≥ 1 section/day," "≥ 7 hrs sleep"
- **UI**: Simple "Progress Rule" section under task details

**2. Inside Task Settings (Edit Screen)**
Every Growth Task card gets an "Edit Rule" option where you can:
- Switch rule type (e.g., from delta_threshold to count_min)
- Adjust thresholds (e.g., from +1 rep to +2 reps)
- Change rolling windows (e.g., 5 connections in 7 days → 7 in 14 days)
- **UI**: Same as creation, but prefilled with current configuration

**3. Triggered During Reviews**
During Day 7 / Day 14 / Weekly Reviews, PJ can auto-flag tasks:
- "This task passed 5× but metric trend = flat → checkbox loop detected"
- Suggests: "Edit Progress Rule → tighten threshold or convert to Maintenance"
- **UI**: Inline "Edit Rule" button right in the review summary

**4. From Missed Task Protocol**
When a Growth Task fails, PJ prompts:
- "Why did it fail?" (reflection questions)
- Suggests tweaks (e.g., reduce scope, adjust threshold)
- If you confirm → PJ updates the Progress Rule automatically
- **UI**: Adaptive rule editor pops up right after a failed attempt

**🔒 Guardrails**
- **No mid-day edits**: To prevent cheating, Progress Rules can only be edited before the next day starts (or only via Missed Task Protocol)
- **Versioning**: Store old rules alongside new ones, so metric history isn't corrupted
- **Validation**: Ensure rule changes maintain data integrity and prevent gaming the system

#### 🔧 Where to Edit a Linked Metric in PJ

Linked Metrics are the foundation of Growth Tasks - they define what you're actually measuring for progress. PJ provides multiple ways to manage and edit these metrics:

**1. At Task Creation**
When you add a Growth Task, PJ requires you to pick (or create) a metric:
- **UI Flow**: Task name → Task type = Growth → "Choose Linked Metric"
- **Options**:
  - Pick from existing (Sleep Hours, Weight Lifted, Pages Read)
  - Or create a new one (custom metric with name + unit)
- **Examples**: "Bench Press Weight × Reps", "Caffeine Intake (mg)", "Meaningful Connections"

**2. Task Settings (Edit Screen)**
Every Growth Task card gets a Linked Metric field in its settings where you can:
- Switch the metric (e.g., from "Steps" to "Calories Burned")
- Edit details (unit = lbs, reps, minutes)
- Re-link to another metric if your focus changes
- **Guardrail**: If you change a linked metric, PJ versions history so past data isn't corrupted

**3. Metric Library / Dashboard**
PJ includes a central Metrics screen (like a library):
- Shows all metrics you've created (Sleep Hours, Caffeine Intake, Bench Press, Connections)
- Lets you edit unit, description, direction (increase/decrease is better)
- Shows which tasks are currently linked to each metric
- **Example**: Metric: "Caffeine Intake (mg)" → linked to task "Caffeine Taper"

**4. During Review or Missed Task Protocol**
If a task keeps failing or flatlining:
- PJ suggests: "Do you want to change the Linked Metric?"
- **Example**: "Strength Training" might be linked to Bench Press, but maybe you want to track Total Training Volume instead
- User can update link right inside the review dialog

**🔒 Guardrails**
- **No mid-day edits**: To prevent gaming, you can only edit a metric before tomorrow starts (or during a review)
- **Versioning**: Keep old metric associations in history → graphs remain accurate
- **One-to-many**: A single metric can be linked to multiple tasks, but a Growth Task must always have at least one linked metric

**📊 Example**
- **Task**: "Strength Training"
- **Linked Metric**: Bench Press Weight × Reps
- **Progress Rule**: delta_threshold (+1 rep or +2.5 lbs)
- **Where to edit?** → Open "Strength Training" task → Settings → Linked Metric → change to "Total Workout Volume" if you want broader tracking

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
