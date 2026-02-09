/// WorkConnect Design System Documentation
///
/// This file defines all design tokens and guidelines for the WorkConnect app.
/// Based on the Figma design system provided.
///
/// Color Palette:
/// - Primary Blue: #2196F3 (Primary actions, links, focus states)
/// - Success Green: #4CAF50 (Positive actions, success states)
/// - Warning Orange: #FF7800 (Alerts, pending states)
/// - Error Red: #F74536 (Errors, destructive actions)
/// - Text Main: #333333 (Primary text)
/// - Text Secondary: #666666 (Secondary text, descriptions)
/// - Background: #F9FAFC (App background)
/// - Surface: #FFFFFF (Cards, elevated surfaces)
/// - Border: #C0C0C0 (Borders, dividers)
///
/// Typography:
/// - Font Family: Inter
/// - Heading 1: 28px, 700 weight
/// - Heading 2: 24px, 700 weight
/// - Heading 3: 20px, 700 weight
/// - Heading 4: 18px, 600 weight
/// - Body: 14-16px, 400-600 weight
/// - Label: 11-12px, 500 weight
/// - Button: 15px, 600 weight
///
/// Spacing (8px base unit):
/// - XS: 4px
/// - SM: 8px
/// - MD: 12px
/// - LG: 16px
/// - XL: 24px
/// - XXL: 32px
/// - XXXL: 48px
///
/// Border Radius:
/// - XS: 4px (small interactive elements)
/// - SM: 8px (input fields, buttons)
/// - MD: 12px (cards, containers)
/// - LG: 16px (large containers)
/// - XL: 24px (modals, dialogs)
/// - FULL: 999px (pills, avatars)
///
/// Shadows:
/// - SM: 1px blur, 0.5px offset
/// - MD: 2px blur, 1px offset
/// - LG: 4px blur, 2px offset
/// - XL: 8px blur, 4px offset
/// - XXL: 16px blur, 8px offset
///
/// Component Specs:
///
/// Buttons:
/// - Height: 44px (primary)
/// - Padding: 12-16px vertical, 24px horizontal
/// - Border Radius: 8px
/// - Font: 15px, 600 weight
/// - Primary Background: #2196F3
/// - Outline: 1.5px border
///
/// Input Fields:
/// - Height: 44px
/// - Padding: 12px vertical, 16px horizontal
/// - Border Radius: 8px
/// - Border: 1px #E0E0E0
/// - Focus Border: 2px #2196F3
/// - Background: #FFFFFF
///
/// Cards:
/// - Border Radius: 12px
/// - Border: 1px #E0E0E0
/// - Shadow: 2px blur offset
/// - Padding: 16px
///
/// Status Badges:
/// - Success: #4CAF50 text on #C8E6C9 background
/// - Warning: #FF7800 text on #FFE0B2 background
/// - Error: #F74536 text on #FFCDD2 background
/// - Active: #2196F3 text on #BBDEFB background
/// - Pending: #FF7800 text on #FFE0B2 background
///
/// Navigation:
/// - Tab Bar Height: 48px
/// - Tab Text: 14px, 500 weight
/// - Active Tab Indicator: 3px height, primary color
/// - Bottom Nav Height: 56px
/// - Icon Size: 24px
///
/// Dialog/Modal:
/// - Border Radius: 24px
/// - Overlay: Black 0.5 opacity
/// - Padding: 24px
///
/// Icons:
/// - Small: 16px
/// - Default: 24px
/// - Large: 32px
/// - XLarge: 48px

library design_system;

// Export all design tokens
export 'colors.dart';
export 'app_constants.dart';
export 'component_styles.dart';
