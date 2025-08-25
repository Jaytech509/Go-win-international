# GO-WIN INTERNATIONAL - MLM Platform Architecture

## Overview
GO-WIN INTERNATIONAL is a dynamic mobile platform for multi-level marketing featuring a unique 14-place board system with seven progressive levels, comprehensive wallet functionality, and educational content.

## Core Features
1. **Board System**: 14-place board with two ranks (Silver/Bronze/Starter + Legend in middle)
2. **7-Level Progression**: Members advance through 7 levels as boards complete
3. **Referral Network**: Two direct referrals per member, multi-level structure
4. **Digital Wallet**: Support for multiple payment methods
5. **Learning Platform**: Educational content by levels
6. **Product Store**: Point-based purchasing system

## Technical Architecture

### Data Models
- **Member**: Profile, level, board position, referrals, points, wallet balance
- **Board**: 14 positions, level, completion status, member assignments
- **Wallet**: Balance, transactions, payment methods
- **Course**: Level-based educational content
- **Product**: Store items purchasable with points
- **Transaction**: Financial operations and point transfers

### Screen Structure
1. **Authentication**: Login/Registration with referral codes
2. **Dashboard**: Overview, statistics, quick actions
3. **Board View**: Visual 14-place board representation
4. **Network Tree**: Referral structure visualization  
5. **Wallet**: Balance, transactions, payment methods
6. **Learning Hub**: Courses and educational content
7. **Product Store**: Items for point purchase
8. **Profile**: Member details and settings

### Key Components
- Board visualization with hierarchical member display
- Referral network tree component
- Payment method integration widgets
- Progress tracking for levels and courses
- Transaction history management

### Business Logic
- Board completion triggers level advancement
- Automatic position assignment for new referrals
- Point earning and spending system
- Multi-level commission calculations
- Course unlocking based on member level

## Implementation Plan
1. Create data models and storage service
2. Build authentication system with referral codes
3. Implement main dashboard and navigation
4. Develop board visualization system
5. Create wallet and payment integration
6. Build learning platform
7. Implement product store
8. Add member profile and settings
9. Test complete flow and debug
10. Final compilation and verification

## File Structure
- `lib/models/` - Data models
- `lib/screens/` - Main app screens
- `lib/services/` - Business logic and storage
- `lib/widgets/` - Reusable components
- `lib/utils/` - Utilities and constants